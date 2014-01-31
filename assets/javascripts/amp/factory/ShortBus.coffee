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

      defaultMessagingKeystore = new DefaultMessagingKeystore()

      defaultIdentityProvider = new DefaultIdentityProvider
        hostname: authenticationProviderHostname
        port: authenticationProviderPort
        serviceUrl: identityProviderServiceUrl
        connectionStrategy: identityProviderConnectionStrategy

      inboundProcessors = []

      if useEncryption
        inboundProcessors.push new EncryptedResponseHandler({keystore: defaultMessagingKeystore})

      inboundProcessors.push new JsonEventSerializer()


      outboundProcessors = []

      outboundProcessors = [
          new OutboundHeadersProcessor({
            authenticationProvider: _authenticationProvider
          }),
          new JsonEventSerializer()
      ]
      if useEncryption
        outboundProcessors.push new EncryptedRequestHandler({
            keystore: defaultMessagingKeystore
            defaultIdentityProvider: defaultIdentityProvider
          })

      defaultMessagingKeystore.setKeypair 'mil.capture.cmf.drivers.TestEncryptedResponse',
        publicKey: null
        privateKey: """
          MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC0soE6EQNZUgIg
          D3emi0Q7yneI88HXqUe7v0c3/2Uzt0mU7TOyT63l/4V33BkBucBOZ2NM/c/lYyDr
          xYQeQzmm9mGeAuEj+TeA3atQ9K17PfvmUS1nOG4Jyb2DBWbOGscVu6A9yRSktqAo
          0rVY5QO44xLP1nSONNKFs9K8T4YeMqgKdwfHDsvzLKGeB3hm0f9OUqJk2jkOSLph
          Sdmm1fZFLwi4gkTYcNnsPsjYmHBtreBOpB61XuvMbGVQXXOSQATMfroE7enItJKk
          KVkgfpXRVICmOgHttt++B0I4+akKM37uGrrCCE9+7Q8173EIsH61W8Rtp6xnJPJj
          YynBlgddAgMBAAECggEBAI97zzGUoNwkSpu6rIAKxjvUIecV6C6ftN5YnOzSWEIg
          oMUpNYu5yZSAujLbCuBb52BaqHdSc+rqNBID3U1KhFUX/5vBHZW7J1+kpYy7PaZH
          KedRPoRgQsBy+ZE4kNHIYZ3YRv3I1iOVAMhpyKa186a0aROwbw0c1K5mhEgTvaPr
          r/lmRZgATSZB5f7Jmz0Izf1x68H4kSbQojSQQ6I975c4xZkmeoVYtG2RciYMm8Yb
          +mYZ9yNlLxv31PYyLIUVe1X3wwTSM8rVFBh8PQvWe2lbuU6VWm6pBFSbEKRQ3d3a
          zUpCp5X3dj/7nML8et5YtjlLH3TpiQZ/fi7WeYR1IOECgYEA2ftHm+RICa0ftJFI
          JIWXMmzify7r0b9Li6mVwQ+9jOl0HKN49OOXCAjVCMk8q5lswQRiK0m39Y/MD3ZZ
          lcUQVdRhcFzqYhiVAaS0ujj/ZO2aGTBfJpiYoM5pCxIZPv4eDEzkyZpAbHhDCHL4
          sALLFd+V8tupZMdlvA6nUvkm4uMCgYEA1DaCRGwD7fbLp9J3LmG9t6NMR6I2kGXE
          MUADyaIRR4cOuSXwTeQmFHHs9YFz7Gf95wrgKzzq1fXpaWuhY3PXkSk2oIc0uE4g
          b/3XIwQ1SYay39V+F/Ux1GBK4GDqtt+ICDrjwtUQCry/X1rnpwkG4Ki+pwcvha+G
          hNnizEzeQL8CgYEApmyG+6qKpXicIExbfCbSjRk8xEWangUjNHpBb6kI2zDSCZt1
          meK5SNUVcSPTQmBc+/DQ0qPx43XqIlQFiadvFViVHCiUeliySxLpONSTiQcvA9Q+
          kUUoIn31DRLAW6vAXTvH4XP3g9k9tJGy9Q7s5sJRxZ2X8u2Z6r51WZAH9GkCgYEA
          uXkWq7R4TsA3yOrC7Y/Rn7Gilq0o4VWAfscDSHRUg95/uMR23az8tzvHLd/BsKpH
          GGrB+Cha2zv9j/zY5jI2AxIxQ2ZIZpkp8pe6M0mXRTbsGYPfnBLaRVMPvkIWglSl
          8QN/Uyaiya+j1zR9aNkT4MC7OQKnv0Dk4jII7iR0z8MCgYBGSuFZ81SiGCmYA9oD
          hC3p9uM+TOT+dzhWJ/uYJAZAKGBHxHkv1mz/EU17R/tifo2Iotb1eVuy6hJyHcvb
          jQhv7kzhmWBG3cc/F9RejrqGbDj2diQ+d6t7XTC+FXxpwqRLyfHoQ0FXshVleE1X
          iTMsUTq1BEXhN4LCHOuKtCEMFQ==
          """
      defaultMessagingKeystore.setKeypair 'mil.capture.cmf.drivers.TestEncryptedRequest',
        publicKey: """
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtLKBOhEDWVICIA93potE
                O8p3iPPB16lHu79HN/9lM7dJlO0zsk+t5f+Fd9wZAbnATmdjTP3P5WMg68WEHkM5
                pvZhngLhI/k3gN2rUPStez375lEtZzhuCcm9gwVmzhrHFbugPckUpLagKNK1WOUD
                uOMSz9Z0jjTShbPSvE+GHjKoCncHxw7L8yyhngd4ZtH/TlKiZNo5Dki6YUnZptX2
                RS8IuIJE2HDZ7D7I2Jhwba3gTqQetV7rzGxlUF1zkkAEzH66BO3pyLSSpClZIH6V
                0VSApjoB7bbfvgdCOPmpCjN+7hq6wghPfu0PNe9xCLB+tVvEbaesZyTyY2MpwZYH
                XQIDAQAB
                """
        privateKey: null

      if(busType == ShortBus.BUSTYPE.RPC)
        new RpcBus(envelopeBus, inboundProcessors, outboundProcessors)
      else
        new EventBus(envelopeBus, inboundProcessors, outboundProcessors)

  return ShortBus