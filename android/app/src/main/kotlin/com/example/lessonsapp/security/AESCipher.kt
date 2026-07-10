package com.example.lessonsapp.security

import android.util.Base64
import java.nio.ByteBuffer
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec

object AESCipher {

    private const val TRANSFORMATION = "AES/GCM/NoPadding"
    private const val IV_LENGTH = 12
    private const val TAG_LENGTH = 128

    fun encrypt(text: String): String {

        val cipher = Cipher.getInstance(TRANSFORMATION)

        cipher.init(
            Cipher.ENCRYPT_MODE,
            KeyStoreHelper.getSecretKey()
        )

        val iv = cipher.iv

        val encrypted = cipher.doFinal(text.toByteArray())

        val byteBuffer =
            ByteBuffer.allocate(iv.size + encrypted.size)

        byteBuffer.put(iv)
        byteBuffer.put(encrypted)

        return Base64.encodeToString(
            byteBuffer.array(),
            Base64.NO_WRAP
        )
    }

    fun decrypt(data: String): String {

        val decoded = Base64.decode(data, Base64.NO_WRAP)

        val byteBuffer = ByteBuffer.wrap(decoded)

        val iv = ByteArray(IV_LENGTH)

        byteBuffer.get(iv)

        val encrypted = ByteArray(byteBuffer.remaining())

        byteBuffer.get(encrypted)

        val cipher = Cipher.getInstance(TRANSFORMATION)

        cipher.init(
            Cipher.DECRYPT_MODE,
            KeyStoreHelper.getSecretKey(),
            GCMParameterSpec(TAG_LENGTH, iv)
        )

        return String(cipher.doFinal(encrypted))
    }

}