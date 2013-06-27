define [
  '../bus/berico/TransportProviderFactory'
  '../webstomp/topology/GlobalTopologyService'
  '../webstomp/ChannelProvider'
  '../webstomp/topology/DefaultApplicationExchangeProvider'
  '../bus/berico/EnvelopeBus'
  '../eventing/berico/serializers/JsonEventSerializer'
  '../eventing/berico/OutboundHeadersProcessor'
  '../eventing/berico/EventBus'
  '../webstomp/topology/RoutingInfoRetriever'
  'underscore'
  '../util/Logger'
  '../bus/berico/EnvelopeHelper'
],
(TransportProviderFactory, GlobalTopologyService, ChannelProvider, DefaultApplicationExchangeProvider, EnvelopeBus, JsonEventSerializer, OutboundHeadersProcessor, EventBus, RoutingInfoRetriever, _, Logger, EnvelopeHelper)->

  class HeaderOverrider
    constructror: (@override)->
    processOutbound: (context)=>
      env = new EnvelopeHelper(context.getEnvelope())
      env.setMessageType @override
      env.setMessageTopic @override
      Logger.log.info "HeaderOverrider.processOutbound >> overrode type and topic headers to #{@override}"

  class ShortBus
    @ROUTING_INFO_URL = "/service/topology/get-routing-info"
    @ROUTE_CREATE_URL = '/service/fallbackRouting/routeCreator'

    @getBus: (config)->
      config = {} if !_.isObject config
      hostname = if _.isString config.hostname then config.hostname else 'localhost'
      port= if _.isNumber config.port then config.port else 15677
      username= if _.isString config.username then config.username else 'app01'
      password= if _.isString config.password then config.password else 'password'
      publishTopicOverride = if _.isString config.publishTopicOverride then config.publishTopicOverride else null

      retriever = new RoutingInfoRetriever(username, password, hostname, port, ShortBus.ROUTING_INFO_URL)

      fallbackProvider = new DefaultApplicationExchangeProvider(hostname,port, ShortBus.ROUTE_CREATE_URL)

      globalTopologyService = new GlobalTopologyService(retriever, null, fallbackProvider)

      channelProvider = new ChannelProvider()

      transportProvider = TransportProviderFactory.getTransportProvider({
        topologyService: globalTopologyService
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
        channelProvider: channelProvider
      })

      envelopeBus = new EnvelopeBus(transportProvider)
      inboundProcessors = [new JsonEventSerializer()]

      outboundProcessors = []
      unless _.isNull publishTopicOverride
        outboundProcessors.push {
          processOutbound: (context)->
            env = new EnvelopeHelper(context.getEnvelope())
            env.setMessageType publishTopicOverride
            env.setMessageTopic publishTopicOverride
            Logger.log.info "HeaderOverrider.processOutbound >> overrode type and topic headers to #{publishTopicOverride}"
        }
      outboundProcessors.push(new OutboundHeadersProcessor(),new JsonEventSerializer())

      new EventBus(envelopeBus, inboundProcessors, outboundProcessors)

  return ShortBus