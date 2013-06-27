define [
  'underscore'
  'stomp'
  'test/websocket/Server.coffee-compiled'
  'test/websocket/Client.coffee-compiled'
  'amp/webstomp/ChannelProvider'
  'sockjs'
  'amp/webstomp/topology/Exchange'
  'amp/bus/Envelope'
  'amp/bus/berico/EnvelopeHelper'
  'amp/webstomp/topology/SimpleTopologyService'

],
(_, Stomp, MockAMQPServer, MockWebSocket, ChannelProvider, SockJS, Exchange, Envelope, EnvelopeHelper, SimpleTopologyService) ->

  ###
    TEST SETUP
  ###

  exchange = new Exchange('test','127.0.0.1','/stomp',15674)

  MockAMQPServer.configure 'http://127.0.0.1:15674/stomp', ->
    @addResponder('message', "CONNECT\naccept-version:1.1,1.0\nheart-beat:0,0\nlogin:guest\npasscode:guest\n\n\u0000")
      .respond("CONNECTED\nsession:session-8N75XCn8cB8VBQxD1gh9fg\nheart-beat:0,0\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n")
    @addResponder('message', "SUBSCRIBE\nid:sub-0\ndestination:/queue/test\n\n\u0000")
      .respond("")
    @addResponder('message', "SEND\ndestination:/queue/test\ncontent-length:22\n\nAre you the Keymaster?\u0000")
      .respond("MESSAGE\nsubscription:sub-0\ndestination:/queue/test\nmessage-id:T_sub-0@@session-LVGptPOnyjbj2jvOc5hC3w@@1\ncontent-length:22\n\nAre you the Keymaster?\u0000")
    @addResponder('message', "DISCONNECT\n\n\u0000")
      .respond("")

  ###
    TESTS
  ###
  describe 'The stomp library', ->
    it 'needs to be able to call the connect callback', (done) ->
      ws = if testConfig.useEmulatedWebSocket then new MockWebSocket('http://127.0.0.1:15674/stomp') else new SockJS('http://127.0.0.1:15674/stomp')
      client = Stomp.over(ws)
      client.heartbeat =
        outgoing: 0
        incoming: 0
      client.connect("guest", "guest", ->
        done()
      )

  describe 'The channel provider', (done)->
    channelProvider = null
    beforeEach ->
      channelProvider = new ChannelProvider({
        connectionFactory: if testConfig.useEmulatedWebSocket then MockWebSocket else SockJS
      })

    it 'should not be null', ->
      assert.notEqual channelProvider, null

    it 'should execute the getConnection deferred', (done) ->

      channelProvider.getConnection(exchange).then (client, existing)->
        assert.notEqual client, null
        assert.ok !existing
        done()

    it 'lets you subscribe and publish', (done) ->
      channelProvider.getConnection(exchange).then (client, existing)->
        message = "Are you the Keymaster?"
        client.subscribe("/queue/test", (output) ->
          assert.equal (_.isEmpty output.body), false
          assert.equal message, output.body
          done()
          )
        client.send("/queue/test", {}, message)
    it 'should let you remove a connection', (done) ->
      channelProvider.getConnection(exchange).then ->
        assert.equal _.keys(channelProvider.connectionPool).length, 1
        channelProvider.removeConnection(exchange).then (removed)->
          assert.ok removed
          assert.equal _.keys(channelProvider.connectionPool).length, 0
          done()