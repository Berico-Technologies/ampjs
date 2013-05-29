define [
  'underscore'
  'src/bus/webstomp/topology/Exchange'
],
(_,Exchange) ->
  describe 'The Topology Exchange', ->
    exchange = null

    beforeEach ->
      exchange = new Exchange("webstomp", "localhost", "/stomp", 15674, "testTopic", "testQueue", "direct", true, false)

    it 'should not be null', ->
      assert.ok _.isObject(exchange)

    it 'should support a printable version of itself', ->
      assert.equal exchange.toString(), '{Name: webstomp, HostName: localhost, VirtualHost: undefined, Port: 15674, RoutingKey: testTopic, Queue Name: testQueue, ExchangeType: direct, IsDurable: true, IsAutoDelete: false}'

    it 'should support a hashable version of itself', ->
      assert.equal exchange.hashCode(), 'd41d8cd98f00b204e9800998ecf8427e'

    it 'should support an equal method', ->
      assert.equal true, exchange.equals(exchange)