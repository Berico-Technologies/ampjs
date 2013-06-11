define [
  'cmf/bus/berico/TransportProviderFactory'
  'underscore'
  'stomp'
  'test/websocket/Server.coffee-compiled'
  'test/websocket/Client.coffee-compiled'
  'cmf/webstomp/ChannelProvider'
  'cmf/webstomp/topology/SimpleTopologyService'
  'cmf/webstomp/TransportProvider'
  'sockjs'
  'cmf/webstomp/topology/Exchange'
  'cmf/bus/Envelope'
  'cmf/bus/berico/EnvelopeHelper'
  'uuid'
  'cmf/eventing/berico/EventRegistration'
  'cmf/eventing/EventHandler'
  'jquery'

],
(TransportProviderFactory, _, Stomp, MockAMQPServer, MockWebSocket, ChannelProvider, SimpleTopologyService, TransportProvider, SockJS, Exchange, Envelope, EnvelopeHelper, uuid, EventRegistration, EventHandler, $) ->

  transportProvider = null

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

