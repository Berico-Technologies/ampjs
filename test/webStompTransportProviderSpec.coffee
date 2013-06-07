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
],
(TransportProviderFactory, _, Stomp, MockAMQPServer, MockWebSocket, ChannelProvider, SimpleTopologyService, TransportProvider, SockJS, Exchange, Envelope, EnvelopeHelper, uuid, EventRegistration, EventHandler, EnvelopeBus) ->

  useEmulatedWebSocket = false
  rabbitmqAddress = 'http://127.0.0.1:15674/stomp'

  describe 'The transport provider', (done)->
    transportProvider = TransportProviderFactory
      .getTransportProvider(TransportProviderFactory.TransportProviders.WebStomp)

    # it 'should not be null', ->
    #   assert.notEqual(transportProvider, null)

    # it 'needs to return a web stomp provider', ->
    #   provider = TransportProviderFactory.getTransportProvider({
    #     transportProvider: TransportProviderFactory.TransportProviders.WebStomp
    #   })
    #   assert.ok(provider instanceof TransportProvider)

    # it 'needs to use appropriate defaults for topo service and channel provider', ->
    #   transportProvider = TransportProviderFactory.getTransportProvider({
    #     transportProvider: TransportProviderFactory.TransportProviders.WebStomp
    #   })

    #   assert.ok(transportProvider.topologyService instanceof SimpleTopologyService)
    #   assert.ok(transportProvider.channelProvider instanceof ChannelProvider)


    it 'should be able to send an envelope', (done)->
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
      env.setMessageType("EventHandler");
      env.setMessageTopic("EventHandler");
      env.setSenderIdentity("dtayman");

      envelopeBus = new EnvelopeBus(transportProvider)
      envelopeBus.register(new EventRegistration(new EventHandler(), [])).then ->
        envelopeBus.send(envelope)

      # transportProvider.register(new EventRegistration(new EventHandler(), [])).then ->
      #     setTimeout(->
      #       transportProvider.send(envelope)
      #       setTimeout(->
      #         done()
      #       ,50)
      #     ,100)

      # routing = transportProvider.topologyService.getRoutingInfo(envelope.getHeaders());
      # transportProvider.channelProvider.getConnection(routing.routes[0].producerExchange, (connection, existing)->
      #   connection.subscribe("cmf.simple.exchange", (output) ->
      #     console.log "hi there"
      #     done()
      #   )
      # )


      # callback = (client, existing) ->
      #   message = "Are you the Keymaster?"
      #   client.subscribe("/queue/test", (output) ->
      #     assert.equal (_.isEmpty output.body), false
      #     assert.equal message, output.body
      #     done()
      #     )
      #   client.send("/queue/test", {}, message)

      # channelProvider.getConnection(exchange, callback)


