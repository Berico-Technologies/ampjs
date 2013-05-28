define [
  'src/bus/TransportProviderFactory'
  'underscore'
  'stomp'
  'test/stomp/StompServer.coffee-compiled'
  'test/websocket/Server.coffee-compiled'
  'src/bus/webstomp/ChannelProvider'
  'src/bus/webstomp/TransportProvider'

],
(TransportProviderFactory, _, Stomp, StompServerMock, Server, ChannelProvider, TransportProvider) ->

  describe 'MockWebsocket', ->
    it 'needs to be able to create a client', (done) ->
      Server.configure 'ws://fake.host', ->
        @addResponder('open', undefined).respond("CONNECTED\nsession:session-8N75XCn8cB8VBQxD1gh9fg\nheart-beat:10000,10000\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n")

      ws = new StompServerMock("ws://fake.host")
      client = Stomp.over(ws)
      client.connect("guest", "guest", ->
        done()
      )

  describe 'The transport provider', (done)->
    transportProvider = null
    beforeEach ->
      transportProvider = TransportProviderFactory.getTransportProvider(TransportProviderFactory.TransportProviders.WebStomp)

    it 'should not be null', ->
      assert.notEqual(transportProvider, null)

    it 'needs to return in web stomp provider', ->

      config =
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp

      provider = TransportProviderFactory.getTransportProvider(config)
      assert provider instanceof TransportProvider

  describe 'The inmemory channel provider', (done)->
    channelProvider = null
    beforeEach ->
      Server.configure 'http://127.0.0.1:15674/stomp', ->
        @addResponder('open', undefined).respond("CONNECTED\nsession:session-8N75XCn8cB8VBQxD1gh9fg\nheart-beat:10000,10000\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n")

      channelProvider = new ChannelProvider({connectionFactory: StompServerMock})

    it 'should not be null', ->
      assert.notEqual channelProvider, null

    it 'should execute the getConnection callback', (done) ->
      callback = (client, existing) ->
        assert.notEqual client, null
        assert.ok !existing
        done()
      route =
          host: "127.0.0.1"
          port: 15674
          vhost: '/stomp'
          exchange: ''

      channelProvider.getConnection(route, false, callback)

    # it 'lets you subscribe and publish', (done) ->


    #   callback = (client, existing) ->
    #     message = "Are you the Keymaster?"
    #     client.subscribe("/queue/test", (output) ->
    #       assert.Equal message, output
    #       done()
    #       )
    #     client.send("/queue/test", {}, message)

    #   route = "test"
    #   channelProvider.getConnection("test", false, callback)



