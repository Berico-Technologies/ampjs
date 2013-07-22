var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['../bus/berico/TransportProviderFactory', '../webstomp/topology/GlobalTopologyService', '../webstomp/ChannelProvider', '../webstomp/topology/DefaultApplicationExchangeProvider', '../bus/berico/EnvelopeBus', '../eventing/berico/serializers/JsonEventSerializer', '../eventing/berico/OutboundHeadersProcessor', '../eventing/berico/EventBus', '../webstomp/topology/RoutingInfoRetriever', 'underscore', '../util/Logger', '../bus/berico/EnvelopeHelper', '../webstomp/topology/DefaultAuthenticationProvider'], function(TransportProviderFactory, GlobalTopologyService, ChannelProvider, DefaultApplicationExchangeProvider, EnvelopeBus, JsonEventSerializer, OutboundHeadersProcessor, EventBus, RoutingInfoRetriever, _, Logger, EnvelopeHelper, DefaultAuthenticationProvider) {
  var HeaderOverrider, ShortBus;
  HeaderOverrider = (function() {
    function HeaderOverrider() {
      this.processOutbound = __bind(this.processOutbound, this);
    }

    HeaderOverrider.prototype.constructror = function(override) {
      this.override = override;
    };

    HeaderOverrider.prototype.processOutbound = function(context) {
      var env;
      env = new EnvelopeHelper(context.getEnvelope());
      env.setMessageType(this.override);
      env.setMessageTopic(this.override);
      return Logger.log.info("HeaderOverrider.processOutbound >> overrode type and topic headers to " + this.override);
    };

    return HeaderOverrider;

  })();
  ShortBus = (function() {
    function ShortBus() {}

    ShortBus.getBus = function(config) {
      var authenticationProvider, authenticationProviderConnectionStrategy, authenticationProviderHostname, authenticationProviderPort, authenticationProviderServiceUrl, channelProvider, channelProviderConnectionFactory, channelProviderConnectionStrategy, envelopeBus, exchangeProviderConnectionStrategy, exchangeProviderHostname, exchangeProviderPort, exchangeProviderServiceUrl, fallbackProvider, fallbackTopoClientProfile, fallbackTopoExchangeHostname, fallbackTopoExchangeName, fallbackTopoExchangePort, fallbackTopoExchangeVhost, globalTopologyService, gtsCacheExpiryTime, gtsExchangeOverrides, inboundProcessors, outboundProcessors, publishTopicOverride, routingInfoConnectionStrategy, routingInfoHostname, routingInfoPort, routingInfoRetriever, routingInfoServiceUrl, transportProvider;
      if (config == null) {
        config = {};
      }
      routingInfoHostname = config.routingInfoHostname, routingInfoPort = config.routingInfoPort, routingInfoServiceUrl = config.routingInfoServiceUrl, routingInfoConnectionStrategy = config.routingInfoConnectionStrategy, exchangeProviderHostname = config.exchangeProviderHostname, exchangeProviderPort = config.exchangeProviderPort, exchangeProviderServiceUrl = config.exchangeProviderServiceUrl, exchangeProviderConnectionStrategy = config.exchangeProviderConnectionStrategy, fallbackTopoClientProfile = config.fallbackTopoClientProfile, fallbackTopoExchangeName = config.fallbackTopoExchangeName, fallbackTopoExchangeHostname = config.fallbackTopoExchangeHostname, fallbackTopoExchangeVhost = config.fallbackTopoExchangeVhost, fallbackTopoExchangePort = config.fallbackTopoExchangePort, gtsCacheExpiryTime = config.gtsCacheExpiryTime, gtsExchangeOverrides = config.gtsExchangeOverrides, channelProviderConnectionStrategy = config.channelProviderConnectionStrategy, channelProviderConnectionFactory = config.channelProviderConnectionFactory, publishTopicOverride = config.publishTopicOverride, authenticationProviderHostname = config.authenticationProviderHostname, authenticationProviderPort = config.authenticationProviderPort, authenticationProviderServiceUrl = config.authenticationProviderServiceUrl, authenticationProviderConnectionStrategy = config.authenticationProviderConnectionStrategy;
      routingInfoRetriever = new RoutingInfoRetriever({
        hostname: routingInfoHostname,
        port: routingInfoPort,
        serviceUrlExpression: routingInfoServiceUrl,
        connectionStrategy: routingInfoConnectionStrategy
      });
      fallbackProvider = new DefaultApplicationExchangeProvider({
        managementHostname: exchangeProviderHostname,
        managementPort: exchangeProviderPort,
        managementServiceUrl: exchangeProviderServiceUrl,
        connectionStrategy: exchangeProviderConnectionStrategy,
        clientProfile: fallbackTopoClientProfile,
        exchangeName: fallbackTopoExchangeName,
        exchangeHostname: fallbackTopoExchangeHostname,
        exchangeVhost: fallbackTopoExchangeVhost,
        exchangePort: fallbackTopoExchangePort
      });
      globalTopologyService = new GlobalTopologyService({
        routingInfoRetriever: routingInfoRetriever,
        cacheExpiryTime: gtsCacheExpiryTime,
        fallbackProvider: fallbackProvider,
        exchangeOverrides: gtsExchangeOverrides
      });
      authenticationProvider = new DefaultAuthenticationProvider({
        hostname: authenticationProviderHostname,
        port: authenticationProviderPort,
        serviceUrl: authenticationProviderServiceUrl,
        connectionStrategy: authenticationProviderConnectionStrategy
      });
      channelProvider = new ChannelProvider({
        connectionStrategy: channelProviderConnectionStrategy,
        connectionFactory: channelProviderConnectionFactory,
        authenticationProvider: authenticationProvider
      });
      transportProvider = TransportProviderFactory.getTransportProvider({
        topologyService: globalTopologyService,
        transportProvider: TransportProviderFactory.TransportProviders.WebStomp,
        channelProvider: channelProvider
      });
      envelopeBus = new EnvelopeBus(transportProvider);
      inboundProcessors = [new JsonEventSerializer()];
      outboundProcessors = [];
      if (!_.isNull(publishTopicOverride)) {
        outboundProcessors.push({
          processOutbound: function(context) {
            var env;
            env = new EnvelopeHelper(context.getEnvelope());
            env.setMessageType(publishTopicOverride);
            env.setMessageTopic(publishTopicOverride);
            return Logger.log.info("HeaderOverrider.processOutbound >> overrode type and topic headers to " + publishTopicOverride);
          }
        });
      }
      outboundProcessors.push(new OutboundHeadersProcessor(), new JsonEventSerializer());
      return new EventBus(envelopeBus, inboundProcessors, outboundProcessors);
    };

    return ShortBus;

  })();
  return ShortBus;
});
