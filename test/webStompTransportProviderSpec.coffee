define [
  'amp/bus/berico/TransportProviderFactory'
  'underscore'
  'stomp'
  'test/websocket/Server'
  'test/websocket/Client'
  'amp/webstomp/ChannelProvider'
  'amp/webstomp/topology/SimpleTopologyService'
  'amp/webstomp/TransportProvider'
  'sockjs'
  'amp/webstomp/topology/Exchange'
  'amp/bus/Envelope'
  'amp/bus/berico/EnvelopeHelper'
  'uuid'
  'amp/eventing/berico/EventRegistration'
  'amp/eventing/EventHandler'
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

