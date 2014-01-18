define [
  'amp/bus/berico/TransportProviderFactory'
  'amp/eventing/berico/serializers/JsonEventSerializer'
  'amp/eventing/berico/EventBus'
  'amp/bus/berico/EnvelopeBus'
  'amp/eventing/berico/OutboundHeadersProcessor'
  'test/websocket/Server'
  'test/websocket/Client'
  'amp/connection/ChannelProvider'
  'amp/connection/topology/DefaultApplicationExchangeProvider'
  'amp/bus/berico/EnvelopeHelper'
  'jquery'
  'amp/connection/topology/DefaultAuthenticationProvider'
],
(TransportProviderFactory, JsonEventSerializer, EventBus, EnvelopeBus, OutboundHeadersProcessor, MockAMQPServer, MockWebSocket, ChannelProvider,DefaultApplicationExchangeProvider,EnvelopeHelper, $, DefaultAuthenticationProvider) ->

  MockAMQPServer.configure 'https://bugsbunny-rabbit.archnet.mil:15678/stomp', ->
    @addResponder('message', "CONNECT\naccept-version:1.1,1.0\nheart-beat:0,0\nlogin:CN=Drew Tayman, CN=Users, DC=archnet, DC=mil\npasscode:ILUXUSHYQW21OqGK+JMvzw==\n\n\u0000")
      .respond("CONNECTED\nsession:session-Cneg9fMRM-eifnLMzU3A_Q\nheart-beat:0,0\nserver:RabbitMQ/3.1.3\nversion:1.1\n\n\u0000")

    @addResponder('message', "SUBSCRIBE\nid:sub-0\ndestination:/amq/queue/0839eeba-a5f7-4019-a428-f751a882b33c#001#GenericMessage\n\n\u0000")
      .respond("")

    @addResponder('message', "SEND\ncmf.bus.message.pattern:cmf.bus.message.pattern#pub_sub\ncmf.bus.message.id:testmessageid\ncmf.bus.message.type:GenericMessage\ncmf.bus.message.topic:GenericMessage\ncmf.bus.message.sender_identity:CN=Drew Tayman, CN=Users, DC=archnet, DC=mil\nSENDER_AUTH_TOKEN:ILUXUSHYQW21OqGK+JMvzw==\ndestination:/exchange/cmf.simple.exchange/GenericMessage\ncontent-length:58\n\n{\"name\":\"Smiley Face\",\"type\":\"ascii\",\"visualization\":\":)\"}\u0000")
      .respond("MESSAGE\nsubscription:sub-0\ndestination:/exchange/cmf.simple.exchange/GenericMessage\nmessage-id:T_sub-0@@session-Cneg9fMRM-eifnLMzU3A_Q@@1\SENDER_AUTH_TOKEN:ILUXUSHYQW21OqGK+JMvzw==\ncmf.bus.message.sender_identity:CN=Drew Tayman, CN=Users, DC=archnet, DC=mil\ncmf.bus.message.topic:GenericMessage\ncmf.bus.message.type:GenericMessage\ncmf.bus.message.id:testmessageid\ncontent-length:58\n\n{\"name\":\"Smiley Face\",\"type\":\"ascii\",\"visualization\":\":)\"}\u0000" )


  class GenericMessage
    constructor: (@name, @type, @visualization)->

  describe 'The event bus', (done)->

    transportProvider = null

    beforeEach ->
      transportProvider = TransportProviderFactory.getTransportProvider({
        topologyService: new DefaultApplicationExchangeProvider({
          managementHostname: "bugsbunny-gts.archnet.mil"
          exchangeHostname: "bugsbunny-rabbit.archnet.mil"
        })
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
        channelProvider: new ChannelProvider({
          connectionFactory: if testConfig.useEmulatedWebSocket then MockWebSocket else SockJS
          authenticationProvider: new DefaultAuthenticationProvider
            hostname: "bugsbunny-anubis.archnet.mil"
        })
      })

      if testConfig.useSimulatedManager
        sinon.stub $, 'ajax',(options)->
          deferred = $.Deferred()
          switch options.url
            when 'https://bugsbunny-gts.archnet.mil:15677/service/fallbackRouting/routeCreator'
              response = '{"statusType":"OK","entity":null,"entityType":null,"metadata":{},"status":200}'
            when 'https://bugsbunny-anubis.archnet.mil:15679/anubis/identity/authenticate'
              response = '{"token":"ILUXUSHYQW21OqGK+JMvzw==","identity":"CN=Drew Tayman, CN=Users, DC=archnet, DC=mil"}'
            else
              console.log "Unable to emulate repsonse to request #{options.url}"

          deferred.resolve(JSON.parse(response))
          return deferred.promise()


    afterEach (done)->
      transportProvider.dispose().then ->
        done()
      $.ajax.restore() if testConfig.useSimulatedManager

    class HeaderOverrider
      processOutbound: (context)->
        env = new EnvelopeHelper(context.getEnvelope())
        env.setMessageId "testmessageid"

    it 'should be able to send an object', (done)->


      payload = new GenericMessage("Smiley Face", "ascii", ":)")

      eventBus = new EventBus(
        new EnvelopeBus(transportProvider),
        [new JsonEventSerializer()], #inbound
        [new HeaderOverrider(), new OutboundHeadersProcessor({
          authenticationProvider: new DefaultAuthenticationProvider
            hostname: "bugsbunny-anubis.archnet.mil"
        }), new JsonEventSerializer()]  #outbound
      )
      eventBus.subscribe({
        getEventType: ->
          return "GenericMessage"
        handle: (arg0, arg1)->
          assert.equal payload.name, arg0.name
          assert.equal payload.type, arg0.type
          assert.equal payload.visualization, arg0.visualization
          done()
        handleFailed: (arg0, arg1)->
        }).then ->
        eventBus.publish(payload)

