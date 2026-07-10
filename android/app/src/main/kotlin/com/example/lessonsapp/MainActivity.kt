package com.example.lessonsapp

import android.os.Bundle
import android.os.Process
import androidx.annotation.NonNull
import com.example.lessonsapp.security.EncryptionHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.lessonsapp/security"
    private val encryptionHelper = EncryptionHelper()

    // TODO: Replace this with your actual release signing certificate base64 hash.
    // Tip: Run your app once, log 'currentSignatureBase64' from EncryptionHelper, and paste it here.
 private val encryptionHelper = EncryptionHelper()

    // This block runs BEFORE onCreate and BEFORE the UI renders.
    init {
        // Run a quick preemptive check for memory manipulation
        val helper = EncryptionHelper()
        if (helper.isFridaDetected()) {
            Process.killProcess(Process.myPid())
            System.exit(1)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Run full validation suite (Signature + Frida)
        verifyEnvironment()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // Double-check security environment on every single method call invocation
            if (performSecurityChecks()) {
                result.error("SECURITY_CRITICAL", "Environment compromise detected.", null)
                return@setMethodCallHandler
            }

            if (call.method == "getSecret") {
                val secretName = call.argument<String>("secretName")
                if (secretName != null) {
                    try {
                        val decryptedValue = encryptionHelper.getDecryptedSecret(secretName)
                        result.success(decryptedValue)
                    } catch (e: Exception) {
                        result.error("DECRYPTION_ERROR", e.message, null)
                    }
                } else {
                    result.error("BAD_ARGUMENT", "Secret key name cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * Executes our active defensive runtime guard checks.
     * Returns true if a threat is discovered, and instantly kills the process.
     */
    private fun performSecurityChecks(): Boolean {
        // 1. Block Frida or Frida-Gadget injections
        if (encryptionHelper.isFridaDetected()) {
            Process.killProcess(Process.myPid())
            System.exit(1)
            return true
        }

        // 2. Block Tampered/Cloned APK modifications (Only run this on Release builds)
        // Skip signature check if running with the default placeholder token to prevent debugging blockades
        if (EXPECTED_SIGNATURE != "YOUR_PRODUCTION_SIGNATURE_BASE64_HASH_HERE") {
            if (encryptionHelper.isAppTampered(applicationContext, EXPECTED_SIGNATURE)) {
                Process.killProcess(Process.myPid())
                System.exit(1)
                return true
            }
        }
        
        return false
    }
    private fun verifyEnvironment() {
        if (encryptionHelper.isFridaDetected() || encryptionHelper.isAppTampered(applicationContext)) {
            Process.killProcess(Process.myPid())
            System.exit(1)
        }
    }
}