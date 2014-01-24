# define [
#   'underscore'
#   'amp/connection/topology/GlobalTopologyService'
#   'amp/bus/berico/EnvelopeHeaderConstants'
#   'amp/connection/topology/RoutingInfoRetriever'
#   'amp/bus/berico/EnvelopeHelper'
#   'amp/connection/topology/DefaultApplicationExchangeProvider'
#   'amp/bus/berico/TransportProviderFactory'
#   'amp/eventing/berico/serializers/JsonEventSerializer'
#   'amp/eventing/berico/EventBus'
#   'amp/bus/berico/EnvelopeBus'
#   'amp/eventing/berico/OutboundHeadersProcessor'
#   'amp/connection/ChannelProvider'
#   'amp/util/Logger'
#   'test/websocket/Server'
#   'test/websocket/Client'
#   'jquery'
#   'amp/connection/topology/DefaultAuthenticationProvider'
# ],
# (_, GlobalTopologyService, EnvelopeHeaderConstants, RoutingInfoRetriever, EnvelopeHelper, DefaultApplicationExchangeProvider, TransportProviderFactory, JsonEventSerializer, EventBus, EnvelopeBus, OutboundHeadersProcessor, ChannelProvider, Logger, MockAMQPServer, MockWebSocket, $, DefaultAuthenticationProvider) ->

#   class HeaderOverrider
#     processOutbound: (context)->
#       env = new EnvelopeHelper(context.getEnvelope())
#       env.setMessageId "testmessageid"
#       env.setMessageType "cmf.security.AccessEvent"
#       env.setMessageTopic "cmf.security.AccessEvent"
#       Logger.log.info "HeaderOverrider.processOutbound >> overrode type and topic headers"

#   class Message
#     constructor: (@interestingStuff)->

#   retriever = null
#   fallbackProvider = null
#   transportProvider = null

#   describe 'The Global Topology Class', ->
#     it 'should initialize without any constructor args', ->
#       service = new GlobalTopologyService()
#       assert.ok _.isObject(service)
#     it 'should accept a routing retriever and fallbackProvider', ->
#       service = new GlobalTopologyService(retriever, null, fallbackProvider)

#       assert.equal retriever, service.routingInfoRetriever
#       assert.equal fallbackProvider, service.fallbackProvider


#   describe 'The Global Topology Service', ->
#     MockAMQPServer.configure 'http://localhost:15674/stomp', ->
#       @addResponder('message',"CONNECT\naccept-version:1.1,1.0\nheart-beat:0,0\nlogin:CN=Test User, CN=Users, DC=archnet, DC=mil\npasscode:4MbBsTPMGkOyFmLRl/Ax5A==\n\n\u0000")
#         .respond("CONNECTED\nsession:session-hrB7nF3u2quJUTjWc5Owgg\nheart-beat:0,0\nserver:RabbitMQ/3.0.4\nversion:1.1\n\n\u0000")

#       @addResponder('message',"SUBSCRIBE\nid:sub-0\ndestination:/amq/queue/security-service\n\n\u0000")
#         .respond("")

#       @addResponder('message', "SEND\ncmf.bus.message.id:testmessageid\ncmf.bus.message.type:cmf.security.AccessEvent\ncmf.bus.message.topic:cmf.security.AccessEvent\ncmf.bus.message.sender_identity:CN=Test User, CN=Users, DC=archnet, DC=mil\nSENDER_AUTH_TOKEN:4MbBsTPMGkOyFmLRl/Ax5A==\ndestination:/exchange/cmf.security/cmf.security\ncontent-length:40\n\n{\"interestingStuff\":\"interesting stuff\"}\u0000")
#         .respond("MESSAGE\nsubscription:sub-0\ndestination:/exchange/cmf.security/cmf.security\nmessage-id:T_sub-0@@session-_-izNu4iMzsblSU57HFbag@@1\ncmf.bus.message.sender_identity:unknown\ncmf.bus.message.topic:cmf.security.AccessEvent\ncmf.bus.message.type:cmf.security.AccessEvent\ncmf.bus.message.id:testmessageid\ncontent-length:40\n\n{\"interestingStuff\":\"interesting stuff\"}\u0000" )


#     beforeEach ->

#       if testConfig.useSimulatedManager
#         sinon.stub $, 'ajax',(options)->
#           deferred = $.Deferred()
#           switch options.url
#             when 'http://app01:password@localhost:15677/service/topology/get-routing-info/my.cool.topic?c=true'
#               response = '{"routes":[]}'
#             when 'http://app01:password@localhost:15677/service/topology/get-routing-info/cmf.security.AccessEvent?c=true'
#               response = '{"routes":[{"consumerExchange":{"arguments":null,"exchangeType":"topic","hostName":"localhost","isAutoDelete":false,"isDurable":false,"name":"cmf.security","port":5672,"queueName":"security-service","routingKey":"cmf.security","virtualHost":"/"},"producerExchange":{"arguments":null,"exchangeType":"topic","hostName":"localhost","isAutoDelete":false,"isDurable":false,"name":"cmf.security","port":5672,"queueName":"security-service","routingKey":"cmf.security","virtualHost":"/"}}]}'
#             when'http://app01:password@localhost:15677/service/topology/get-routing-info/amp.examples.notifier.core.UserNotification?c=true'
#               response = '{"routes":[{"consumerExchange":{"arguments":null,"exchangeType":"direct","hostName":"localhost","isAutoDelete":false,"isDurable":false,"name":"cmf.apps","port":5672,"queueName":"","routingKey":"amq.direct","virtualHost":"/"},"producerExchange":{"arguments":null,"exchangeType":"direct","hostName":"localhost","isAutoDelete":false,"isDurable":false,"name":"cmf.apps","port":5672,"queueName":"","routingKey":"amq.direct","virtualHost":"/"}}]}'
#             when 'http://localhost:15677/service/fallbackRouting/routeCreator'
#               response = '{"statusType":"OK","entity":null,"entityType":null,"metadata":{},"status":200}'
#             when 'https://localhost:15679/anubis/identity/authenticate'
#               response = '{"token":"4MbBsTPMGkOyFmLRl/Ax5A==","identity":"CN=Test User, CN=Users, DC=archnet, DC=mil"}'
#             else
#               Logger.log.error "Unable to emulate repsonse to request #{options.url}"
#           deferred.resolve(JSON.parse(response))
#           return deferred.promise()

#       retriever = new RoutingInfoRetriever({
#         hostname: "localhost"
#         connectionStrategy: (topic)->"http://app01:password@#{@hostname}:#{@port}#{@serviceUrlExpression}/#{topic}?c=true"
#       })
#       fallbackProvider = new DefaultApplicationExchangeProvider({
#           connectionStrategy: ->
#             return "http://#{@managementHostname}:#{@managementPort}#{@managementServiceUrl}"
#           clientProfile: 'TESTONLY'
#           exchangePort: 15674
#         })

#     afterEach ->
#       $.ajax.restore() if testConfig.useSimulatedManager

#     it 'should use default routing when GTS presents no routes', (done)->
#       service = new GlobalTopologyService({
#         routingInfoRetriever: retriever
#         exchangeOverrides:
#           port: 15674
#           vHost: '/stomp'
#         fallbackProvider: fallbackProvider
#       })
#       routingHints = {}
#       routingHints[EnvelopeHeaderConstants.MESSAGE_TOPIC] = "my.cool.topic"

#       service.getRoutingInfo(routingHints).then (routing)->
#         assert.ok _.isObject _.pluck routing.routes, 'consumerExchange'
#         assert.ok _.isObject _.pluck routing.routes, 'producerExchange'
#         done();

#     it 'should return GTS routes when an existing route is queried', (done)->
#       service = new GlobalTopologyService({
#         routingInfoRetriever: retriever
#         exchangeOverrides:
#           port: 15674
#           vHost: '/stomp'
#       })
#       routingHints = {}
#       routingHints[EnvelopeHeaderConstants.MESSAGE_TOPIC] = "amp.examples.notifier.core.UserNotification"

#       service.getRoutingInfo(routingHints).then (routeInfo)->
#         exchange = routeInfo.routes[0].consumerExchange
#         assert.notEqual null, exchange
#         assert.equal exchange.name, 'cmf.apps'
#         assert.equal exchange.hostName, 'localhost'
#         assert.equal exchange.port, 15674
#         assert.equal exchange.routingKey, "amq.direct"
#         assert.equal exchange.exchangeType, 'direct'
#         assert.equal exchange.isDurable, false
#         assert.equal exchange.isAutoDelete, false
#         assert.equal exchange.arguments, null
#         done();

#     it 'should allow publishing and subscribing to GTS topics', (done)->
#       transportProvider = TransportProviderFactory.getTransportProvider({
#         topologyService: new GlobalTopologyService({
#           routingInfoRetriever: retriever
#           exchangeOverrides:
#             port: 15674
#             vHost: '/stomp'
#         })
#         transportProvider: TransportProviderFactory.TransportProviders.WebStomp
#         channelProvider: new ChannelProvider({
#           connectionFactory: if testConfig.useEmulatedWebSocket then MockWebSocket else SockJS
#           connectionStrategy: (exchange) ->
#             return "http://#{exchange.hostName}:#{exchange.port}#{exchange.vHost}"
#         })
#       })
#       eventBus = new EventBus(
#         new EnvelopeBus(transportProvider),
#         [new JsonEventSerializer()], #inbound
#         [new HeaderOverrider(), new OutboundHeadersProcessor(), new JsonEventSerializer()]  #outbound
#       )
#       eventBus.subscribe({
#         getEventType: ->
#           return "cmf.security.AccessEvent"
#         handle: (arg0, arg1)->
#           assert.equal "interesting stuff", arg0.interestingStuff
#           done()
#         handleFailed: (arg0, arg1)->
#         }).then ->
#         eventBus.publish(new Message('interesting stuff'))