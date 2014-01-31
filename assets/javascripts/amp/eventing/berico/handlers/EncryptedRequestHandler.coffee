define [
  'jquery'
  '../../../bus/berico/EnvelopeHelper'
  '../../../util/Logger'
  'JSEncrypt'
  'amp/util/AesUtil'
  'amp/connection/topology/DefaultMessagingKeystore'
  'amp/connection/topology/DefaultIdentityProvider'
],
($, EnvelopeHelper, Logger, JSEncrypt, AesUtil, DefaultMessagingKeystore, DefaultIdentityProvider)->
  class EncryptedRequestHandler

    constructor: (config={})->
      {@keystore, @defaultIdentityProvider}=config

      unless _.isObject @keystore then @authenticationProvider = new DefaultMessagingKeystore()
      unless _.isObject @defaultIdentityProvider then @defaultIdentityProvider = new DefaultIdentityProvider()

    processInbound: (context)->
      null

    processOutbound: (context)->
      deferred = $.Deferred()
      Logger.log.info "EncryptedResponseHandler.processOutbound >> setting properties for encrypted response"

      envelopeHelper = new EnvelopeHelper(context.getEnvelope())

      if envelopeHelper.isPubSub()
        @_getPublicKey(envelopeHelper.getMessageTopic()).then (publicKey)->
          envelopeHelper.setHeader "sender_public_key", JSON.stringify(publicKey)
          deferred.resolve()

      deferred.promise()

    _getPublicKey: (topic)->
      deferred = $.Deferred()
      if @keystore.hasKeypair topic
        Logger.log.info "EncryptedResponseHandler._getPublicKey >> keystore hit, returning public key"
        deferred.resolve(@keystore.getPublicKey(topic))
      else
        Logger.log.info "EncryptedResponseHandler._getPublicKey >> keystore miss, querying identity provider"
        @defaultIdentityProvider.getIdentity(topic).then (reply)=>
          @keystore.setKeypair(topic, reply)
          deferred.resolve(@keystore.getPublicKey(topic))
      return deferred.promise()
