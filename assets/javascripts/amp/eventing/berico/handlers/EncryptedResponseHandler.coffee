define [
  '../../../bus/berico/EnvelopeHelper'
  '../../../util/Logger'
  'JSEncrypt'
  'amp/util/AesUtil'
  'amp/connection/topology/DefaultMessagingKeystore'
],
(EnvelopeHelper, Logger, JSEncrypt, AesUtil, DefaultMessagingKeystore)->
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
        anubisIdentity = JSON.parse(envelopeHelper.getSenderAuthToken())

        #now use our private RSA key to decrypt the AES symmetric key from the identity token
        decryptor = new JSEncrypt()
        privateKey = @keystore.getPrivateKey envelopeHelper.getMessageTopic()
        decryptor.setPrivateKey privateKey
        passPhrase = decryptor.decrypt(anubisIdentity.key).replace(/(\r\n|\n|\r)/gm,"")


        if passPhrase == false
          Logger.log.info "EncryptedResponseHandler.processInbound >> failed to decrypt passphrase"

        else
          ###
            TODO: these need to be randomly generated per or maybe topic???!!!
          ###
          iv = "F27D5C9927726BCEFE7510B1BDD3D137"
          salt = "3FF2EC019C627B945225DEBAD71A01B6985FE84C95A70EB132882F88C0A59A55"
          ###
            TODO: these need to be randomly generated per or maybe topic???!!!
          ###
          keySize = 256
          iterations = iterationCount = 1000

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