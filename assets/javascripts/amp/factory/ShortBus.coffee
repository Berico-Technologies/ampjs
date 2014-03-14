define [
  '../bus/berico/TransportProviderFactory'
  '../connection/topology/GlobalTopologyService'
  '../connection/topology/SimpleTopologyService'
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
  '../connection/topology/SimpleAuthenticationProvider'
  '../connection/topology/DefaultIdentityProvider'
  '../eventing/berico/RpcBus'
  '../eventing/berico/handlers/EncryptedResponseHandler'
  '../eventing/berico/handlers/EncryptedRequestHandler'
  '../connection/topology/DefaultMessagingKeystore'
],
(TransportProviderFactory, GlobalTopologyService, SimpleTopologyService, ChannelProvider, DefaultApplicationExchangeProvider, EnvelopeBus, JsonEventSerializer, OutboundHeadersProcessor, EventBus, RoutingInfoRetriever, _, Logger, EnvelopeHelper, DefaultAuthenticationProvider, SimpleAuthenticationProvider, DefaultIdentityProvider, RpcBus, EncryptedResponseHandler, EncryptedRequestHandler, DefaultMessagingKeystore)->

  class ShortBus
    @BUSTYPE:
      RPC: 'rpc'
      EVENT: 'event'
    @TOPOLOGY_SERVICE:
      GTS: "GTS"
      SIMPLE: "SIMPLE"
    @AUTHENTICATION_PROVIDER:
      SIMPLE: "SIMPLE"
      DEFAULT: "DEFAULT"

    @getBus: (config={})->
      {
        routingInfoHostname, routingInfoPort, routingInfoServiceUrl,
        routingInfoConnectionStrategy, exchangeProviderHostname, exchangeProviderPort,
        exchangeProviderServiceUrl, exchangeProviderConnectionStrategy, fallbackTopoClientProfile,
        fallbackTopoExchangeName, fallbackTopoExchangeHostname, fallbackTopoExchangeVhost,
        fallbackTopoExchangePort, gtsCacheExpiryTime, gtsExchangeOverrides,
        channelProviderConnectionStrategy, channelProviderConnectionFactory, publishTopicOverride,
        authenticationProviderHostname, authenticationProviderPort, authenticationProviderServiceUrl,
        authenticationProviderConnectionStrategy, busType, identityProviderServiceUrl, identityProviderConnectionStrategy, messagingFactory, topologyService, simpleTopologyServiceClientProfile, simpleTopologyServiceName, simpleTopologyServiceHostname, simpleTopologyServiceVirtualHost, simpleTopologyServicePort, authenticationProvider, authenticationProviderUsername, authenticationProviderPassword, useEncryption, defaultMessagingKeystore
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

      if topologyService == @TOPOLOGY_SERVICE.SIMPLE
        console.log "choosing simple..."
        transportProviderTopologyService = new SimpleTopologyService
          clientProfile: simpleTopologyServiceClientProfile
          name: simpleTopologyServiceName
          hostname: simpleTopologyServiceHostname
          virtualHost: simpleTopologyServiceVirtualHost
          port: simpleTopologyServicePort
      else
        transportProviderTopologyService = new GlobalTopologyService
          routingInfoRetriever: routingInfoRetriever
          cacheExpiryTime: gtsCacheExpiryTime
          fallbackProvider: fallbackProvider
          exchangeOverrides: gtsExchangeOverrides

      if authenticationProvider == @AUTHENTICATION_PROVIDER.SIMPLE
        _authenticationProvider = new SimpleAuthenticationProvider
          username: authenticationProviderUsername
          password: authenticationProviderPassword
      else
        _authenticationProvider = new DefaultAuthenticationProvider
          hostname: authenticationProviderHostname
          port: authenticationProviderPort
          serviceUrl: authenticationProviderServiceUrl
          connectionStrategy: authenticationProviderConnectionStrategy


      channelProvider = new ChannelProvider({
        connectionStrategy: channelProviderConnectionStrategy
        connectionFactory: channelProviderConnectionFactory
        authenticationProvider: _authenticationProvider
        messagingFactory: messagingFactory
        })

      transportProvider = TransportProviderFactory.getTransportProvider({
        topologyService: transportProviderTopologyService
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp
        channelProvider: channelProvider
      })

      envelopeBus = new EnvelopeBus(transportProvider)


      defaultIdentityProvider = new DefaultIdentityProvider
        hostname: authenticationProviderHostname
        port: authenticationProviderPort
        serviceUrl: identityProviderServiceUrl
        connectionStrategy: identityProviderConnectionStrategy
        authenticationProvider: _authenticationProvider

      defaultMessagingKeystore = new DefaultMessagingKeystore
        defaultIdentityProvider: defaultIdentityProvider

      inboundProcessors = []

      if useEncryption
        inboundProcessors.push new EncryptedResponseHandler
          keystore: defaultMessagingKeystore
          authenticationProvider: _authenticationProvider

      inboundProcessors.push new JsonEventSerializer()


      outboundProcessors = []

      outboundProcessors = [
          new OutboundHeadersProcessor({
            authenticationProvider: _authenticationProvider
          }),
          new JsonEventSerializer()
      ]
      if useEncryption
        outboundProcessors.push new EncryptedRequestHandler
            keystore: defaultMessagingKeystore


      if(busType == ShortBus.BUSTYPE.RPC)
        new RpcBus(envelopeBus, inboundProcessors, outboundProcessors)
      else
        new EventBus(envelopeBus, inboundProcessors, outboundProcessors)

  return ShortBus