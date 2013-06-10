define [
  'src/bus/TransportProviderFactory'
  'underscore'
  'stomp'
  'test/websocket/Server.coffee-compiled'
  'test/websocket/Client.coffee-compiled'
  'src/bus/webstomp/ChannelProvider'
  'src/bus/webstomp/topology/SimpleTopologyService'
  'src/bus/webstomp/TransportProvider'
  'sockjs'
  'src/bus/webstomp/topology/Exchange'
  'src/bus/Envelope'
  'src/bus/EnvelopeHelper'
  'uuid'
  'src/eventing/EventRegistration'
  'src/eventing/EventHandler'
  'src/bus/EnvelopeBus'
  'jquery'
  'src/eventing/serializers/JsonEventSerializer'
  'src/bus/EventBus'
  'src/eventing/OutboundHeadersProcessor'
],
(TransportProviderFactory, _, Stomp, MockAMQPServer, MockWebSocket, ChannelProvider, SimpleTopologyService, TransportProvider, SockJS, Exchange, Envelope, EnvelopeHelper, uuid, EventRegistration, EventHandler, EnvelopeBus, $, JsonEventSerializer, EventBus, OutboundHeadersProcessor) ->

  #configure mocha to ignore the global variable jquery throws jsonp responses into
  mocha.setup
    globals: [ 'jQuery*' ]

  class GenericMessage
    constructor: (@name, @type, @visualization)->

  useEmulatedWebSocket = false
  rabbitmqAddress = 'http://127.0.0.1:15674/stomp'

  describe 'The transport provider', (done)->
    transportProvider = TransportProviderFactory
      .getTransportProvider(TransportProviderFactory.TransportProviders.WebStomp)

    it 'should not be null', ->
      assert.notEqual(transportProvider, null)

    it 'needs to return a web stomp provider', ->
      provider = TransportProviderFactory.getTransportProvider({
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
      })
      assert.ok(provider instanceof TransportProvider)

    it 'needs to use appropriate defaults for topo service and channel provider', ->
      transportProvider = TransportProviderFactory.getTransportProvider({
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
      })

      assert.ok(transportProvider.topologyService instanceof SimpleTopologyService)
      assert.ok(transportProvider.channelProvider instanceof ChannelProvider)

  describe 'The transport provider', (done)->

    transportProvider = null

    beforeEach ->
      transportProvider = TransportProviderFactory
        .getTransportProvider(TransportProviderFactory.TransportProviders.WebStomp)

    afterEach (done)->
      transportProvider.dispose().then ->
        done()

    it 'should be able to send an envelope', (done)->

      payload = new GenericMessage("Slimer", "ascii", "
                             __---__
                            -       _--______
                       __--( /     \ )XXXXXXXXXXXXX_
                     --XXX(   O   O  )XXXXXXXXXXXXXXX-
                    /XXX(       U     )        XXXXXXX\
                  /XXXXX(              )--_  XXXXXXXXXXX\
                 /XXXXX/ (      O     )   XXXXXX   \XXXXX\
                 XXXXX/   /            XXXXXX   \__ \XXXXX----
                 XXXXXX__/          XXXXXX         \__----  -
         ---___  XXX__/          XXXXXX      \__         ---
           --  --__/   ___/\  XXXXXX            /  ___---=
             -_    ___/    XXXXXX              '--- XXXXXX
               --\/XXX\ XXXXXX                      /XXXXX
                 \XXXXXXXXX                        /XXXXX/
                  \XXXXXX                        _/XXXXX/
                    \XXXXX--__/              __-- XXXX/
                     --XXXXXXX---------------  XXXXX--
                        \XXXXXXXXXXXXXXXXXXXXXXXX-
                          --XXXXXXXXXXXXXXXXXX-
                "
      )


      eventBus = new EventBus(
        new EnvelopeBus(transportProvider),
        [new JsonEventSerializer()], #inbound
        [new OutboundHeadersProcessor(), new JsonEventSerializer()]  #outbound
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

