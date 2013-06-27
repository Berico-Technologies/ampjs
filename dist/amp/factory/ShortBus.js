var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['../bus/berico/TransportProviderFactory', '../webstomp/topology/GlobalTopologyService', '../webstomp/ChannelProvider', '../webstomp/topology/DefaultApplicationExchangeProvider', '../bus/berico/EnvelopeBus', '../eventing/berico/serializers/JsonEventSerializer', '../eventing/berico/OutboundHeadersProcessor', '../eventing/berico/EventBus', '../webstomp/topology/RoutingInfoRetriever', 'underscore', '../util/Logger', '../bus/berico/EnvelopeHelper'], function(TransportProviderFactory, GlobalTopologyService, ChannelProvider, DefaultApplicationExchangeProvider, EnvelopeBus, JsonEventSerializer, OutboundHeadersProcessor, EventBus, RoutingInfoRetriever, _, Logger, EnvelopeHelper) {
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

    ShortBus.ROUTING_INFO_URL = "/service/topology/get-routing-info";

    ShortBus.ROUTE_CREATE_URL = '/service/fallbackRouting/routeCreator';

    ShortBus.getBus = function(config) {
      var channelProvider, envelopeBus, fallbackProvider, globalTopologyService, hostname, inboundProcessors, outboundProcessors, password, port, publishTopicOverride, retriever, transportProvider, username;

      if (!_.isObject(config)) {
        config = {};
      }
      hostname = _.isString(config.hostname) ? config.hostname : 'localhost';
      port = _.isNumber(config.port) ? config.port : 15677;
      username = _.isString(config.username) ? config.username : 'app01';
      password = _.isString(config.password) ? config.password : 'password';
      publishTopicOverride = _.isString(config.publishTopicOverride) ? config.publishTopicOverride : null;
      retriever = new RoutingInfoRetriever(username, password, hostname, port, ShortBus.ROUTING_INFO_URL);
      fallbackProvider = new DefaultApplicationExchangeProvider(hostname, port, ShortBus.ROUTE_CREATE_URL);
      globalTopologyService = new GlobalTopologyService(retriever, null, fallbackProvider);
      channelProvider = new ChannelProvider();
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
