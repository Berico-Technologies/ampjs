define [
  '../../../bus/berico/EnvelopeHelper'
  '../../../util/Logger'
  'JSEncrypt'
  'amp/util/AesUtil'
  'amp/connection/topology/DefaultMessagingKeystore'
  'JSRSASIGN'
],
(EnvelopeHelper, Logger, JSEncrypt, AesUtil, DefaultMessagingKeystore, KEYUTIL)->
  class EncryptedResponseHandler

    constructor: (config={})->
      {@keystore}=config

      unless _.isObject @keystore then @authenticationProvider = new DefaultMessagingKeystore()

    processInbound: (context)->

      #first build an envelope helper from the raw envelope received
      envelopeHelper = new EnvelopeHelper(context.getEnvelope())

      if envelopeHelper.isPubSub()
        Logger.log.info "EncryptedResponseHandler.processInbound >>  message is pubsub, proceeding with decryption"
        #it can only be an encrypted message if we're dealing  with pubsub

        #then extract the authentication token
        anubisIdentity = envelopeHelper.getHeader("rsa_encrypted_secret_key")

        #now use our private RSA key to decrypt the AES symmetric key from the identity token
        decryptor = new JSEncrypt()
        rsaKey = KEYUTIL.getRSAKeyFromPlainPKCS8PEM("-----BEGIN PRIVATE KEY-----\n"+this.keystore.getPrivateKey(envelopeHelper.getMessageTopic())+"\n-----BEGIN PRIVATE KEY-----")
        decryptor.setPrivateKey(KEYUTIL.getPEM(rsaKey, "PKCS1PRV"))
        passPhrase = decryptor.decrypt(anubisIdentity).replace(/(\r\n|\n|\r)/gm,"")


        if passPhrase == false
          Logger.log.info "EncryptedResponseHandler.processInbound >> failed to decrypt passphrase"

        else

          iv = envelopeHelper.getHeader("symmetric_key_iv")
          salt = envelopeHelper.getHeader("symmetric_key_salt")
          keySize = envelopeHelper.getHeader("symmetric_key_size")
          iterations = iterationCount = envelopeHelper.getHeader("symmetric_key_count")

          aesUtil = new AesUtil(keySize, iterationCount)
          cipherText = envelopeHelper.getPayload()
          decrypted = aesUtil.decrypt(salt, iv, passPhrase, cipherText)
          if decrypted.length > 0
            Logger.log.info "EncryptedResponseHandler.processInbound >> successfully decrypted message"
            envelopeHelper.setPayload(decrypted)
            return true
          else
            Logger.log.info "EncryptedResponseHandler.processInbound >> failed to decrypt message"
            return false

      else
        Logger.log.info "EncryptedResponseHandler.processInbound >>  message is not pubsub, ignoring"


    processOutbound: (context)->
      null