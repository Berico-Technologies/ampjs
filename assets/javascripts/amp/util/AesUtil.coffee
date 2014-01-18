define [
  "CryptoJSLib/aes"
  'CryptoJSLib/pbkdf2'
  'CryptoJSLib/enc-base64'
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
        hasher: CryptoJS.algo.SHA384
      CryptoJS.PBKDF2 passPhrase, salt, config

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
###
define(["CryptoJSLib/aes", 'CryptoJSLib/pbkdf2'], function() {
  var AesUtil;
  return AesUtil = (function() {
    function AesUtil(keySize, iterationCount) {
      this.keySize = keySize / 32;
      this.iterationCount = iterationCount;
    }

    AesUtil.prototype.generateKey = function(salt, passPhrase) {
      var config;
      salt = CryptoJS.enc.Hex.parse(salt);
      config = {
        keySize: this.keySize,
        iterations: this.iterationCount
      };
      return CryptoJS.PBKDF2(passPhrase, salt, config);
    };

    AesUtil.prototype.encrypt = function(salt, iv, passPhrase, plainText) {
      var encrypted, key;
      key = this.generateKey(salt, passPhrase);
      encrypted = CryptoJS.AES.encrypt(plainText, key, {
        iv: CryptoJS.enc.Hex.parse(iv)
      });
      return encrypted.ciphertext.toString(CryptoJS.enc.Base64);
    };

    AesUtil.prototype.decrypt = function(salt, iv, passPhrase, cipherText) {
      var cipherParams, decrypted, key;
      key = this.generateKey(salt, passPhrase);
      cipherParams = CryptoJS.lib.CipherParams.create({
        ciphertext: CryptoJS.enc.Base64.parse(cipherText)
      });
      decrypted = CryptoJS.AES.decrypt(cipherParams, key, {
        iv: CryptoJS.enc.Hex.parse(iv)
      });
      return decrypted.toString(CryptoJS.enc.Utf8);
    };

    return AesUtil;

  })();
});
RunLink
###