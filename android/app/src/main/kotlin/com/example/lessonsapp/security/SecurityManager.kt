fun getApiKey(): String {

    val masterKey =
        MasterKeyManager.get()

    return AESCipher.decrypt(
        Secrets.API_KEY,
        masterKey
    )
}