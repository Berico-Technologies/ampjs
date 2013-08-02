define [
  'amp/bus/berico/TransportProviderFactory'
  'amp/eventing/berico/serializers/JsonEventSerializer'
  'amp/eventing/berico/EventBus'
  'amp/bus/berico/EnvelopeBus'
  'amp/eventing/berico/OutboundHeadersProcessor'
  'test/websocket/Server.coffee-compiled'
  'test/websocket/Client.coffee-compiled'
  'amp/webstomp/ChannelProvider'
  'amp/webstomp/topology/DefaultApplicationExchangeProvider'
  'amp/bus/berico/EnvelopeHelper'
  'jquery'
],
(TransportProviderFactory, JsonEventSerializer, EventBus, EnvelopeBus, OutboundHeadersProcessor, MockAMQPServer, MockWebSocket, ChannelProvider,DefaultApplicationExchangeProvider,EnvelopeHelper, $) ->

  MockAMQPServer.configure 'http://127.0.0.1:15674/stomp', ->
    @addResponder('message',"CONNECT\naccept-version:1.1,1.0\nheart-beat:0,0\nlogin:CN=Test User, CN=Users, DC=archnet, DC=mil\npasscode:4MbBsTPMGkOyFmLRl/Ax5A==\n\n\u0000")
      .respond("CONNECTED\nsession:session-WbnKIBsb4i9nvnxhYHQo_A\nheart-beat:0,0\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n\u0000")

    @addResponder('message',"SUBSCRIBE\nid:sub-0\ndestination:/amq/queue/TESTONLY#001#GenericMessage\n\n\u0000")
      .respond("")

    @addResponder('message', "SEND\ncmf.bus.message.id:testmessageid\ncmf.bus.message.type:GenericMessage\ncmf.bus.message.topic:GenericMessage\ncmf.bus.message.sender_identity:unknown\ndestination:/exchange/cmf.simple.exchange/GenericMessage\ncontent-length:58\n\n{\"name\":\"Smiley Face\",\"type\":\"ascii\",\"visualization\":\":)\"}\u0000"  )
      .respond("MESSAGE\nsubscription:sub-0\ndestination:/exchange/cmf.simple.exchange/GenericMessage\nmessage-id:T_sub-0@@session-7SIBEp8KAROK0Jb61n0eog@@1\ncmf.bus.message.sender_identity:unknown\ncmf.bus.message.topic:GenericMessage\ncmf.bus.message.type:GenericMessage\ncmf.bus.message.id:testmessageid\ncontent-length:58\n\n{\"name\":\"Smiley Face\",\"type\":\"ascii\",\"visualization\":\":)\"}\u0000" )


  class GenericMessage
    constructor: (@name, @type, @visualization)->

  describe 'The event bus', (done)->

    transportProvider = null

    beforeEach ->
      transportProvider = TransportProviderFactory.getTransportProvider({
        topologyService: new DefaultApplicationExchangeProvider({
          connectionStrategy: ->
            return "http://#{@managementHostname}:#{@managementPort}#{@managementServiceUrl}"
          clientProfile: 'TESTONLY'
          exchangePort: 15674
        })
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
        channelProvider: new ChannelProvider({
          connectionFactory: if testConfig.useEmulatedWebSocket then MockWebSocket else SockJS
          connectionStrategy: (exchange) ->
            return "http://#{exchange.hostName}:#{exchange.port}#{exchange.vHost}"
        })
      })

      if testConfig.useSimulatedManager
        sinon.stub $, 'ajax',(options)->
          deferred = $.Deferred()
          switch options.url
            when 'http://localhost:15677/service/fallbackRouting/routeCreator'
              response = '{"statusType":"OK","entity":null,"entityType":null,"metadata":{},"status":200}'
            when 'https://localhost:15679/anubis/identity/authenticate'
              response = '{"token":"4MbBsTPMGkOyFmLRl/Ax5A==","identity":"CN=Test User, CN=Users, DC=archnet, DC=mil"}'
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
        [new HeaderOverrider(), new OutboundHeadersProcessor(), new JsonEventSerializer()]  #outbound
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

