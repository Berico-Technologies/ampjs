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
  '../webstomp/topology/DefaultAuthenticationProvider'
  '../eventing/berico/RpcBus'
],
(TransportProviderFactory, GlobalTopologyService, ChannelProvider, DefaultApplicationExchangeProvider, EnvelopeBus, JsonEventSerializer, OutboundHeadersProcessor, EventBus, RoutingInfoRetriever, _, Logger, EnvelopeHelper, DefaultAuthenticationProvider, RpcBus)->

  class ShortBus
    @BUSTYPE:
        RPC: 'rpc'
        EVENT: 'event'

    @getBus: (config={})->
      {
        routingInfoHostname, routingInfoPort, routingInfoServiceUrl,
        routingInfoConnectionStrategy, exchangeProviderHostname, exchangeProviderPort,
        exchangeProviderServiceUrl, exchangeProviderConnectionStrategy, fallbackTopoClientProfile,
        fallbackTopoExchangeName, fallbackTopoExchangeHostname, fallbackTopoExchangeVhost,
        fallbackTopoExchangePort, gtsCacheExpiryTime, gtsExchangeOverrides,
        channelProviderConnectionStrategy, channelProviderConnectionFactory, publishTopicOverride,
        authenticationProviderHostname, authenticationProviderPort, authenticationProviderServiceUrl,
        authenticationProviderConnectionStrategy, busType
      } = config


      routingInfoRetriever = new RoutingInfoRetriever({
        hostname: routingInfoHostname
        port: routingInfoPort
        serviceUrlExpression: routingInfoServiceUrl
        connectionStrategy: routingInfoConnectionStrategy
      })

      fallbackProvider = new DefaultApplicationExchangeProvider({
        managementHostname: exchangeProviderHostname
        managementPort: exchangeProviderPort
        managementServiceUrl: exchangeProviderServiceUrl
        connectionStrategy: exchangeProviderConnectionStrategy
        clientProfile: fallbackTopoClientProfile
        exchangeName: fallbackTopoExchangeName
        exchangeHostname: fallbackTopoExchangeHostname
        exchangeVhost: fallbackTopoExchangeVhost
        exchangePort: fallbackTopoExchangePort
        })

      globalTopologyService = new GlobalTopologyService({
        routingInfoRetriever: routingInfoRetriever
        cacheExpiryTime: gtsCacheExpiryTime
        fallbackProvider: fallbackProvider
        exchangeOverrides: gtsExchangeOverrides
        })

      authenticationProvider = new DefaultAuthenticationProvider({
        hostname: authenticationProviderHostname
        port: authenticationProviderPort
        serviceUrl: authenticationProviderServiceUrl
        connectionStrategy: authenticationProviderConnectionStrategy
      })

      channelProvider = new ChannelProvider({
        connectionStrategy: channelProviderConnectionStrategy
        connectionFactory: channelProviderConnectionFactory
        authenticationProvider: authenticationProvider
        })

      transportProvider = TransportProviderFactory.getTransportProvider({
        topologyService: globalTopologyService
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
        channelProvider: channelProvider
      })

      envelopeBus = new EnvelopeBus(transportProvider)
      inboundProcessors = [new JsonEventSerializer()]

      outboundProcessors = []

      outboundProcessors = [
          new OutboundHeadersProcessor({
            authenticationProvider: authenticationProvider
          }),
          new JsonEventSerializer()
      ]

      if(busType == ShortBus.BUSTYPE.RPC)
        new RpcBus(envelopeBus, inboundProcessors, outboundProcessors)
      else
        new EventBus(envelopeBus, inboundProcessors, outboundProcessors)

  return ShortBus