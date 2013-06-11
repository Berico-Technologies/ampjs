define [
  'cmf/bus/berico/TransportProviderFactory'
  'cmf/eventing/berico/serializers/JsonEventSerializer'
  'cmf/eventing/berico/EventBus'
  'cmf/bus/berico/EnvelopeBus'
  'cmf/eventing/berico/OutboundHeadersProcessor'
],
(TransportProviderFactory, JsonEventSerializer, EventBus, EnvelopeBus, OutboundHeadersProcessor) ->

  #configure mocha to ignore the global variable jquery throws jsonp responses into
  mocha.setup
    globals: [ 'jQuery*' ]

  class GenericMessage
    constructor: (@name, @type, @visualization)->

  describe 'The transport provider', (done)->

    transportProvider = null

    beforeEach ->
      transportProvider = TransportProviderFactory
        .getTransportProvider(TransportProviderFactory.TransportProviders.WebStomp)

    afterEach (done)->
      transportProvider.dispose().then ->
        done()

    it 'should be able to send an envelope', (done)->

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

