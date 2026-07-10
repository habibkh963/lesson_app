val enc = AESCipher.encrypt("Hello World")

Log.d("SEC", enc)

Log.d("SEC", AESCipher.decrypt(enc))