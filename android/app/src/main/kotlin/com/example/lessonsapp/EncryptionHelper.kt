package com.example.lessonsapp.security

import android.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

class EncryptionHelper {
private val EXPECTED_SHA256 = byteArrayOf(
        0x60, 0x58, 0xB9, 0x05, 0xA8, 0x2C, 0x91, 0x6D, 
        0xAD, 0x0C, 0xC9, 0x7D, 0x3D, 0xCE, 0x85, 0x4E,
        0x8D, 0x6E, 0x2B, 0xEE, 0x24, 0x72, 0x95, 0xED, 
        0xD1, 0x06, 0xB0, 0x1E, 0x6D, 0xBD, 0x5F, 0xD1
    )

    fun isAppTampered(context: Context): Boolean {
        try {
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES, 28) {
                PackageManager.GET_SIGNING_CERTIFICATES
            } else {
                @Suppress("DEPRECATION")
                PackageManager.GET_SIGNATURES
            }

            val packageInfo = context.packageManager.getPackageInfo(context.packageName, flags)
            
            // Get the active signature block
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                packageInfo.signatures
            }

            if (signatures.isNullOrEmpty()) return true

            for (sig in signatures) {
                val md = MessageDigest.getInstance("SHA-256")
                val currentHash = md.digest(sig.toByteArray())
                
                // Compare the raw bytes safely
                if (currentHash.contentEquals(EXPECTED_SHA256)) {
                    return false // Matches perfectly!
                }
            }
        } catch (e: Exception) {
            return true // Fallback to failing secure
        }
        return true // Signature mismatch
    }

    /**
     * Anti-Frida & Anti-Gadget: Scans the process memory map (/proc/self/maps) 
     * to look for injected "frida", "gadget", or "gum" library fragments.
     */
    fun isFridaDetected(): Boolean {
        // 1. Memory Maps Inspection
        try {
            val mapsFile = File("/proc/self/maps")
            BufferedReader(FileReader(mapsFile)).use { reader ->
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    val lowerLine = line!!.lowercase()
                    if (lowerLine.contains("frida") || lowerLine.contains("gadget") || lowerLine.contains("gum-js")) {
                        return true
                    }
                }
            }
        } catch (e: Exception) {
            // Ignore or log
        }

        // 2. Default Frida Server Port Check (TCP 27042)
        // Runs on a separate thread context internally to avoid NetworkOnMainThreadException
        try {
            var fridaPortOpen = false
            val thread = Thread {
                try {
                    val socket = Socket("localhost", 27042)
                    socket.close()
                    fridaPortOpen = true
                } catch (e: Exception) {
                    // Port is closed, which is safe
                }
            }
            thread.start()
            thread.join(500) // Don't block app boot for more than 500ms
            if (fridaPortOpen) return true
        } catch (e: Exception) { }

        return false
    }
    private fun getBootstrapKey(): SecretKeySpec {
        // Your obfuscated 32-byte AES key split to prevent binary string matching
        val part1 = "T9#vK2!qLm7@xP4\$".toByteArray(Charsets.UTF_8)
        val part2 = "Hs8^Za1&wEr5YuIo".toByteArray(Charsets.UTF_8)
        return SecretKeySpec(part1 + part2, "AES")
    }

    /**
     * Internal decryption logic that processes the Base64 "IV:Ciphertext"
     */
    private fun decrypt(combinedString: String): String {
        val parts = combinedString.split(":")
        if (parts.size != 2) throw IllegalArgumentException("Malformed secret.")

        val ivBytes = Base64.decode(parts[0], Base64.DEFAULT)
        val cipherBytes = Base64.decode(parts[1], Base64.DEFAULT)

        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, getBootstrapKey(), IvParameterSpec(ivBytes))
        
        return String(cipher.doFinal(cipherBytes), Charsets.UTF_8)
    }

    /**
     * Resolves which encrypted secret to decrypt based on the requested key name
     */
    fun getDecryptedSecret(secretName: String): String {
        val encryptedTarget = when (secretName) {
            "apiKey" -> Secrets.ENCRYPTED_API_KEY
            "xApiKey" -> Secrets.ENCRYPTED_X_API_KEY
            "baseUrl" -> Secrets.ENCRYPTED_BASE_URL
            "pass" -> Secrets.ENCRYPTED_PASS
            else -> throw IllegalArgumentException("Secret key '$secretName' not found.")
        }
        return decrypt(encryptedTarget)
    }
}