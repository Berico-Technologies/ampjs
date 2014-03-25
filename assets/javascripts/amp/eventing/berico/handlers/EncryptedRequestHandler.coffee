define [
  'jquery'
  '../../../bus/berico/EnvelopeHelper'
  '../../../util/Logger'
  'JSEncrypt'
  'amp/util/AesUtil'
  'amp/connection/topology/DefaultMessagingKeystore'
],
($, EnvelopeHelper, Logger, JSEncrypt, AesUtil, DefaultMessagingKeystore, DefaultIdentityProvider)->
  class EncryptedRequestHandler

    constructor: (config={})->
      {@keystore, @defaultIdentityProvider}=config

      unless _.isObject @keystore then @authenticationProvider = new DefaultMessagingKeystore()

    processInbound: (context)->
      null

    processOutbound: (context)->

      envelopeHelper = new EnvelopeHelper(context.getEnvelope())

      Logger.log.info "EncryptedResponseHandler.processOutbound >> setting properties to request encrypted response"
      deferred = $.Deferred()
      @keystore.getProofKey(envelopeHelper.getMessageTopic()).then(
        (proofKey)=>
          @keystore.getSignedIdentityToken(envelopeHelper.getMessageTopic()).then(
            (signedIdentityToken)=>
              #put the identity and credentials into the headers
              envelopeHelper.setSenderIdentity JSON.parse(signedIdentityToken)['identityToken']['identity']

              #i'm crying a little bit...
              envelopeHelper.setSenderCredentials JSON.stringify
                signedIdentityToken: JSON.parse(signedIdentityToken)

              hmac = CryptoJS.algo.HMAC.create(CryptoJS.algo.SHA256, proofKey);
              hmac.update(JSON.stringify(envelopeHelper.getEnvelope()))
              hmacHash = CryptoJS.enc.Hex.stringify(hmac.finalize())

              envelopeHelper.setDigitalSignature JSON.stringify(hmacHash)

              deferred.resolve()

            () =>
              deferred.reject {error: 'EncryptedRequestHandler.processOutbound >> error getting signed identity token', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
          )

        () =>
          deferred.reject {error: 'EncryptedRequestHandler.processOutbound >> error getting proof key', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
      )

      deferred.promise()

    _getPublicKey: (topic)->
      deferred = $.Deferred()
      if @keystore.hasKeypair topic
        Logger.log.info "EncryptedResponseHandler._getPublicKey >> keystore hit, returning public key"
        deferred.resolve(@keystore.getPublicKey(topic))
      else
        Logger.log.info "EncryptedResponseHandler._getPublicKey >> keystore miss, querying identity provider"
        @defaultIdentityProvider.getIdentity(topic).then (reply)=>
          @keystore.setIdentityContext(topic, reply)
          deferred.resolve(@keystore.getPublicKey(topic))
      return deferred.promise()
