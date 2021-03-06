define [
  'underscore'
  'amp/webstomp/topology/Exchange'
  'amp/webstomp/topology/SimpleTopologyService'
  'amp/bus/berico/EnvelopeHeaderConstants'
],
(_,Exchange, SimpleTopologyService, EnvelopeHeaderConstants) ->
  describe 'The Topology Exchange', ->
    exchange = null

    beforeEach ->
      exchange = new Exchange("webstomp", "localhost", "/stomp", 15674, "testTopic", "testQueue", "direct", true, false)

    it 'should not be null', ->
      assert.ok _.isObject(exchange)

    it 'should support a printable version of itself', ->
      assert.equal exchange.toString(), '{Name: webstomp, HostName: localhost, VirtualHost: /stomp, Port: 15674, RoutingKey: testTopic, Queue Name: testQueue, ExchangeType: direct, IsDurable: true, IsAutoDelete: false}'

    it 'should support an equal method', ->
      assert.equal true, exchange.equals(exchange)

  describe 'The Simple Topology Service', ->

    it 'should be able to be called with no constructor arguments', ->
      simpleTopologyService = new SimpleTopologyService()
      assert.equal simpleTopologyService.hostname, '127.0.0.1'
      assert.equal simpleTopologyService.name, 'cmf.simple.exchange'
      assert.equal simpleTopologyService.port, 15678
      assert.equal simpleTopologyService.virtualHost, '/stomp'
      assert.equal simpleTopologyService.queue_number, 0

    it 'should accept constructor overrides', ->
      simpleTopologyService = new SimpleTopologyService({
        clientProfile: null
        name: 'myexchange'
        hostname: 'myhostname'
        virtualHost: 'myvhost'
        port: 1234
      })
      assert.notEqual simpleTopologyService.clientProfile, null
      assert.equal simpleTopologyService.hostname, 'myhostname'
      assert.equal simpleTopologyService.name, 'myexchange'
      assert.equal simpleTopologyService.port, 1234
      assert.equal simpleTopologyService.virtualHost, 'myvhost'
      assert.equal simpleTopologyService.queue_number, 0

    it 'should return routing info', ->
      simpleTopologyService = new SimpleTopologyService()
      headers = {}
      headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = "mytopic"

      simpleTopologyService.getRoutingInfo(headers).then (routingInfo)->
        assert.notEqual null, routingInfo

        exchange = routingInfo.routes[0].consumerExchange
        assert.notEqual null, exchange
        assert.equal exchange.name, 'cmf.simple.exchange'
        assert.equal exchange.hostName, '127.0.0.1'
        assert.equal exchange.vHost, '/stomp'
        assert.equal exchange.port, 15678
        assert.equal exchange.routingKey, 'mytopic'
        assert.equal exchange.exchangeType, 'direct'
        assert.equal exchange.isDurable, false
        assert.equal exchange.isAutoDelete, true
        assert.equal exchange.arguments, null

