define [
  'underscore'
  'amp/eventing/berico/handlers/EncryptedRequestHandler'
  'amp/eventing/berico/handlers/EncryptedResponseHandler'
  'amp/connection/topology/DefaultMessagingKeystore'
  'uuid'
  'amp/bus/Envelope'
  'amp/bus/berico/EnvelopeHeaderConstants'
  'amp/bus/berico/EnvelopeHelper'
  'amp/eventing/berico/ProcessingContext'
  'amp/factory/ShortBus'
  'jquery'
  'amp/util/AesUtil'
],
(_,EncryptedRequestHandler, EncryptedResponseHandler, DefaultMessagingKeystore, uuid, Envelope, EnvelopeHeaderConstants, EnvelopeHelper, ProcessingContext, ShortBus, $, AesUtil) ->
  describe 'The EncryptionHandlers and Keystore', ->

    it 'should correctly prepare an encrypted message request', (done)->
      @timeout(10000)
      shortBus = ShortBus.getBus
        exchangeProviderHostname: "gts.archnet.mil"
        exchangeProviderPort: 15677
        routingInfoHostname: "gts.archnet.mil"
        routingInfoPort: 15677
        authenticationProviderHostname: "anubis.archnet.mil"
        authenticationProviderPort: 15678
        fallbackTopoExchangeHostname: "rabbit.archnet.mil"
        fallbackTopoExchangePort: 15680
        useEncryption: true
        busType: 'event'
      shortBus.subscribe({
        getEventType: ->
          return "mil.capture.cmf.drivers.TestEncryptedResponse"
        handle: (arg0, arg1)->
          console.log arg0.message
          assert.equal arg0.message, "This is my rifle. There are many like it, but this one is mine.My rifle is my best friend. It is my life. I must master it as I must master my life.My rifle, without me, is useless. Without my rifle, I am useless. I must fire my rifle true. I must shoot straighter than my enemy who is trying to kill me. I must shoot him before he shoots me. I will...My rifle and I know that what counts in this war is not the rounds we fire, the noise of our burst, nor the smoke we make. We know that it is the hits that count. We will hit...My rifle is human, even as I, because it is my life. Thus, I will learn it as a brother. I will learn its weaknesses, its strength, its parts, its accessories, its sights and its barrel. I will keep my rifle clean and ready, even as I am clean and ready. We will become part of each other. We will...Before God, I swear this creed. My rifle and I are the defenders of my country. We are the masters of our enemy. We are the saviors of my life.So be it, until victory is America's and there is no enemy."
          done()
        handleFailed: (arg0, arg1)->
        }).then ->
          shortBus.publish({'body':'interesting stuff...'}, 'mil.capture.cmf.drivers.TestEncryptedRequest')
