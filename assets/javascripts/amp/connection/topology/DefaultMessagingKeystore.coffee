define [
  'jquery'
  'underscore'
  '../../util/Logger'
  'Hashtable'
],
($,_, Logger, Hashtable)->

  class DefaultMessagingKeystore
    constructor: ->
      #this will hold our topic / private key | public key mapping
      #its instantiated as a closure to prevent snooping
      keystore = new Hashtable()

      @getPublicKey= (topic)->
        keypair = keystore.get(topic)
        unless _.isNull keypair then keypair.publicKey else null

      @getPrivateKey= (topic)->
        keypair = keystore.get(topic)
        unless _.isNull keypair then keypair.privateKey else null

      @hasKeypair = (topic)->
        !_.isNull keystore.get(topic)

      @setKeypair = (topic, keypair)->
        {publicKey, privateKey} = keypair
        keystore.put topic,
          privateKey: keypair.privateKey
          publicKey: keypair.publicKey