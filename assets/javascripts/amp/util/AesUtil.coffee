define [
  "CryptoJS_AES"
  'CryptoJS_PBKDF2'
  'CryptoJS_ENC_BASE64'
],
()->
  class AesUtil
    constructor: (keySize, iterationCount)->
      @keySize = keySize / 32
      @iterationCount = iterationCount
    generateKey: (salt, passPhrase) ->
      salt = CryptoJS.enc.Hex.parse(salt)
      config =
        keySize: @keySize
        iterations: @iterationCount
        hasher: CryptoJS.algo.SHA512
      key = CryptoJS.PBKDF2 passPhrase, salt, config
      return key

    encrypt: (salt, iv, passPhrase, plainText)->
      key = @generateKey(salt, passPhrase);
      encrypted = CryptoJS.AES.encrypt(plainText,key,{ iv: CryptoJS.enc.Hex.parse(iv) })
      encrypted.ciphertext.toString(CryptoJS.enc.Base64)
    decrypt: (salt, iv, passPhrase, cipherText)->
      key = @generateKey(salt, passPhrase)
      cipherParams = CryptoJS.lib.CipherParams.create
        ciphertext: CryptoJS.enc.Base64.parse cipherText

      decrypted = CryptoJS.AES.decrypt(cipherParams,key,{ iv: CryptoJS.enc.Hex.parse(iv) })
      decrypted.toString(CryptoJS.enc.Utf8)
