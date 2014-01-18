define [
  '../bus/berico/TransportProviderFactory'
  '../connection/topology/GlobalTopologyService'
  '../connection/ChannelProvider'
  '../connection/topology/DefaultApplicationExchangeProvider'
  '../bus/berico/EnvelopeBus'
  '../eventing/berico/serializers/JsonEventSerializer'
  '../eventing/berico/OutboundHeadersProcessor'
  '../eventing/berico/EventBus'
  '../connection/topology/RoutingInfoRetriever'
  'underscore'
  '../util/Logger'
  '../bus/berico/EnvelopeHelper'
  '../connection/topology/DefaultAuthenticationProvider'
  '../connection/topology/DefaultIdentityProvider'
  '../eventing/berico/RpcBus'
  '../eventing/berico/handlers/EncryptedResponseHandler'
  '../eventing/berico/handlers/EncryptedRequestHandler'
  '../connection/topology/DefaultMessagingKeystore'

],
(TransportProviderFactory, GlobalTopologyService, ChannelProvider, DefaultApplicationExchangeProvider, EnvelopeBus, JsonEventSerializer, OutboundHeadersProcessor, EventBus, RoutingInfoRetriever, _, Logger, EnvelopeHelper, DefaultAuthenticationProvider, DefaultIdentityProvider, RpcBus, EncryptedResponseHandler, EncryptedRequestHandler, DefaultMessagingKeystore)->

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
        authenticationProviderConnectionStrategy, busType, identityProviderServiceUrl, identityProviderConnectionStrategy, messagingFactory
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
        messagingFactory: messagingFactory
        })

      transportProvider = TransportProviderFactory.getTransportProvider({
        topologyService: globalTopologyService
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
        channelProvider: channelProvider
      })

      envelopeBus = new EnvelopeBus(transportProvider)

      defaultMessagingKeystore = new DefaultMessagingKeystore()

      defaultIdentityProvider = new DefaultIdentityProvider
        hostname: authenticationProviderHostname
        port: authenticationProviderPort
        serviceUrl: identityProviderServiceUrl
        connectionStrategy: identityProviderConnectionStrategy

      inboundProcessors = [
        new EncryptedResponseHandler({keystore: defaultMessagingKeystore}),
        new JsonEventSerializer()
      ]

      outboundProcessors = [
          new OutboundHeadersProcessor({
            authenticationProvider: authenticationProvider
          }),
          new JsonEventSerializer()
          new EncryptedRequestHandler({
            keystore: defaultMessagingKeystore
            defaultIdentityProvider: defaultIdentityProvider
          })
      ]

      if(busType == ShortBus.BUSTYPE.RPC)
        new RpcBus(envelopeBus, inboundProcessors, outboundProcessors)
      else
        new EventBus(envelopeBus, inboundProcessors, outboundProcessors)

  return ShortBus