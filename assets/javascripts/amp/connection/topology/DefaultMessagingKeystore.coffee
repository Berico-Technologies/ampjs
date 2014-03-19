define [
  'jquery'
  'underscore'
  '../../util/Logger'
  'Hashtable'
  'amp/connection/topology/DefaultIdentityProvider'
],
($,_, Logger, Hashtable, DefaultIdentityProvider)->

  class DefaultMessagingKeystore
    constructor: (config={})->
      #this will hold our topic / identity context
      #its instantiated as a closure to prevent snooping
      {keystore, @defaultIdentityProvider}=config

      unless _.isObject keystore then keystore = new Hashtable()
      unless _.isObject @defaultIdentityProvider then @defaultIdentityProvider = new DefaultIdentityProvider()

      getIdentityContext = (topic)->
        deferred = $.Deferred()
        if @hasKeypair topic
          Logger.log.info "DefaultMessagingKeystore.getIdentityContext >> keystore hit, returning context"
          deferred.resolve(keystore.get(topic))
        else
          Logger.log.info "EncryptedResponseHandler.getIdentityContext >> keystore miss, querying identity provider"
          @defaultIdentityProvider.getIdentity(topic).then (reply)=>
            @setIdentityContext(topic, reply)
            deferred.resolve(keystore.get(topic))
        return deferred.promise()

      getIdentityContextProperty = (topic, property)->
        deferred = $.Deferred()
        getIdentityContext.call(@,topic).then (context)->
          unless _.isNull context then deferred.resolve(context[property]) else deferred.reject(null)
        return deferred.promise()

      @getSignedIdentityToken= (topic)->
        getIdentityContextProperty.call @, topic, "signedIdentityToken"

      @getPrivateKey= (topic)->
        keystore.get(topic)["privateKey"]

      @getProofKey = (topic)->
        getIdentityContextProperty.call @, topic, "proofKey"

      @hasKeypair = (topic)->
        !_.isNull keystore.get(topic)

      @setIdentityContext = (topic, context)->
        keystore.put topic,
          privateKey: context.privateKey
          proofKey: context.proofKey
          signedIdentityToken: context.signedIdentityToken