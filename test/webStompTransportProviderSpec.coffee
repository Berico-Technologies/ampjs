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
],
(TransportProviderFactory, _, Stomp, MockAMQPServer, MockWebSocket, ChannelProvider, SimpleTopologyService, TransportProvider, SockJS, Exchange, Envelope, EnvelopeHelper, uuid) ->

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

    it 'should be able to send an envelope', (done) ->
      transportProvider = TransportProviderFactory
        .getTransportProvider(TransportProviderFactory.TransportProviders.WebStomp)
      envelope = new Envelope()
      payload = "
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

      envelope.setPayload(payload)
      env = new EnvelopeHelper(envelope)
      env.setMessageId(uuid.v1());
      env.setMessageType("messageType");
      env.setMessageTopic("messageType");
      env.setSenderIdentity("dtayman");

      transportProvider.send(envelope)
      setTimeout(->
          done()
        ,2000)