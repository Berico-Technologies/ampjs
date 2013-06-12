define [
  'cmf/bus/berico/TransportProviderFactory'
  'cmf/eventing/berico/serializers/JsonEventSerializer'
  'cmf/eventing/berico/EventBus'
  'cmf/bus/berico/EnvelopeBus'
  'cmf/eventing/berico/OutboundHeadersProcessor'
  'test/websocket/Server.coffee-compiled'
  'test/websocket/Client.coffee-compiled'
  'cmf/webstomp/ChannelProvider'
  'jquery'
],
(TransportProviderFactory, JsonEventSerializer, EventBus, EnvelopeBus, OutboundHeadersProcessor, MockAMQPServer, MockWebSocket, ChannelProvider,$) ->

  MockAMQPServer.configure testConfig.rabbitmqAddress, ->
    @addResponder('message',"CONNECT\naccept-version:1.1,1.0\nheart-beat:0,0\nlogin:guest\npasscode:guest\n\n\u0000")
      .respond("CONNECTED\nsession:session-0A2vqAej3d9BG-AommYNUA\nheart-beat:0,0\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n\u0000")

    @addResponder('message',"SUBSCRIBE\nid:sub-0\ndestination:/queue/7bbf51b5-abfe-41c8-94b7-6b30349c4245#001#GenericMessage\n\n\u0000")
      .respond("CONNECTED\nsession:session-0A2vqAej3d9BG-AommYNUA\nheart-beat:0,0\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n\u0000")

    @addResponder('message', "SEND\ndestination:/exchange/cmf.simple.exchange/GenericMessage\ncontent-length:1086\n\n{\"name\":\"Slimer\",\"type\":\"ascii\",\"visualization\":\"                             __---__                            -       _--______                       __--( /      )XXXXXXXXXXXXX_                     --XXX(   O   O  )XXXXXXXXXXXXXXX-                    /XXX(       U     )        XXXXXXX                  /XXXXX(              )--_  XXXXXXXXXXX                 /XXXXX/ (      O     )   XXXXXX   XXXXX                 XXXXX/   /            XXXXXX   __ XXXXX----                 XXXXXX__/          XXXXXX         __----  -         ---___  XXX__/          XXXXXX      __         ---           --  --__/   ___/  XXXXXX            /  ___---=             -_    ___/    XXXXXX              '--- XXXXXX               --/XXX XXXXXX                      /XXXXX                 XXXXXXXXX                        /XXXXX/                  XXXXXX                        _/XXXXX/                    XXXXX--__/              __-- XXXX/                     --XXXXXXX---------------  XXXXX--                        XXXXXXXXXXXXXXXXXXXXXXXX-                          --XXXXXXXXXXXXXXXXXX-                \"}\u0000")
      .respond("MESSAGE\nsubscription:sub-0\ndestination:/exchange/cmf.simple.exchange/GenericMessage\nmessage-id:T_sub-0@@session-Nag03lcQwoZVnD7mnZfJ7A@@1\ncontent-length:1086\n\n{\"name\":\"Slimer\",\"type\":\"ascii\",\"visualization\":\"                             __---__                            -       _--______                       __--( /      )XXXXXXXXXXXXX_                     --XXX(   O   O  )XXXXXXXXXXXXXXX-                    /XXX(       U     )        XXXXXXX                  /XXXXX(              )--_  XXXXXXXXXXX                 /XXXXX/ (      O     )   XXXXXX   XXXXX                 XXXXX/   /            XXXXXX   __ XXXXX----                 XXXXXX__/          XXXXXX         __----  -         ---___  XXX__/          XXXXXX      __         ---           --  --__/   ___/  XXXXXX            /  ___---=             -_    ___/    XXXXXX              '--- XXXXXX               --/XXX XXXXXX                      /XXXXX                 XXXXXXXXX                        /XXXXX/                  XXXXXX                        _/XXXXX/                    XXXXX--__/              __-- XXXX/                     --XXXXXXX---------------  XXXXX--                        XXXXXXXXXXXXXXXXXXXXXXXX-                          --XXXXXXXXXXXXXXXXXX-                \"}\u0000")


  class GenericMessage
    constructor: (@name, @type, @visualization)->

  describe 'The event bus', (done)->

    transportProvider = null

    beforeEach ->

      transportProvider = TransportProviderFactory.getTransportProvider({
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
        channelProvider: new ChannelProvider({
          connectionFactory: if testConfig.useEmulatedWebSocket then MockWebSocket else SockJS
        })
      })
      if testConfig.useSimulatedManager
        sinon.stub $, 'ajax',(options)->
          deferred = $.Deferred()
          deferred.resolve()
          return deferred.promise()


    afterEach (done)->
      transportProvider.dispose().then ->
        done()
      $.ajax.restore() if testConfig.useSimulatedManager

    it 'should be able to send an object', (done)->


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

