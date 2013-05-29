define [
  'src/bus/TransportProviderFactory'
  'underscore'
  'stomp'
  'test/websocket/Server.coffee-compiled'
  'test/websocket/Client.coffee-compiled'
  'src/bus/webstomp/ChannelProvider'
  'src/bus/webstomp/TransportProvider'
  'sockjs'

],
(TransportProviderFactory, _, Stomp, MockAMQPServer, MockWebSocket, ChannelProvider, TransportProvider, SockJS) ->

  ###
    TEST SETUP
  ###
  window.loggingLevel = 'all';
  useEmulatedWebSocket = false
  rabbitmqAddress = 'http://127.0.0.1:15674/stomp'
  route =
    host: "127.0.0.1"
    port: 15674
    vhost: '/stomp'
    exchange: ''
  MockAMQPServer.configure rabbitmqAddress, ->
    @addResponder('message', "CONNECT\naccept-version:1.1,1.0\nheart-beat:10000,10000\nlogin:guest\npasscode:guest\n\n\u0000")
      .respond("CONNECTED\nsession:session-8N75XCn8cB8VBQxD1gh9fg\nheart-beat:10000,10000\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n")
    @addResponder('message', "SUBSCRIBE\nid:sub-0\ndestination:/queue/test\n\n\u0000")
      .respond("")
    @addResponder('message', "SEND\ndestination:/queue/test\ncontent-length:22\n\nAre you the Keymaster?\u0000")
      .respond("MESSAGE\nsubscription:sub-0\ndestination:/queue/test\nmessage-id:T_sub-0@@session-8Oa_pQMYogjsdRUwW2jHdw@@1\ncontent-length:22\n\nAre you the Keymaster?")
    @addResponder('message', "DISCONNECT\n\n\u0000")
      .respond("")

  ###
    TESTS
  ###
  describe 'The stomp library', ->
    it 'needs to be able to call the connect callback', (done) ->
      ws = if useEmulatedWebSocket then new MockWebSocket(rabbitmqAddress) else new SockJS(rabbitmqAddress)
      client = Stomp.over(ws)
      client.connect("guest", "guest", ->
        # done()
      )

  describe 'The transport provider', (done)->
    transportProvider = TransportProviderFactory
      .getTransportProvider(TransportProviderFactory.TransportProviders.WebStomp)

    it 'should not be null', ->
      assert.notEqual(transportProvider, null)

    it 'needs to return a web stomp provider', ->
      provider = TransportProviderFactory.getTransportProvider({
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
      })
      assert provider instanceof TransportProvider

  describe 'The channel provider', (done)->
    channelProvider = null
    beforeEach ->
      channelProvider = new ChannelProvider({
        connectionFactory: if useEmulatedWebSocket then MockWebSocket else SockJS
      })

    it 'should not be null', ->
      assert.notEqual channelProvider, null

    it 'should execute the getConnection callback', (done) ->
      callback = (client, existing) ->
        assert.notEqual client, null
        assert.ok !existing
        done()

      channelProvider.getConnection(route, false, callback)

    it 'lets you subscribe and publish', (done) ->
      callback = (client, existing) ->
        message = "Are you the Keymaster?"
        client.subscribe("/queue/test", (output) ->
          assert.equal (_.isEmpty output.body), false
          assert.equal message, output.body
          done()
          )
        client.send("/queue/test", {}, message)

      channelProvider.getConnection(route, false, callback)

    it 'should let you remove a connection', (done) ->
      channelProvider.getConnection(route, false, ->
        channelProvider.removeConnection(route, (removed)->
          assert.ok removed
          assert.equal _.keys(channelProvider.connectionPool).length, 0
          done()
        )
      )
