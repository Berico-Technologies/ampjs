define(['../../webstomp/TransportProvider', '../../webstomp/ChannelProvider', '../../webstomp/topology/SimpleTopologyService', 'underscore', '../../util/Logger'], function(WebStompTransportProvider, WebStompChannelProvider, SimpleTopologyService, _, Logger) {
  var TransportFactory;
  TransportFactory = (function() {
    function TransportFactory() {}

    TransportFactory.TransportProviders = {
      WebStomp: 'webstomp'
    };

    TransportFactory.TopologyServices = {
      Simple: 'simple'
    };

    TransportFactory.ChannelFactories = {
      WebStomp: 'webstomp'
    };

    TransportFactory.getTransportProvider = function(config) {
      var channelProvider, topologyService;
      Logger.log.info("TransportFactory.getTransportProvider >> getting transport provider");
      if (!_.isObject(config) && _.isString(config)) {
        config = {
          transportProvider: config
        };
      }
      if (!_.isObject(config.topologyService) && _.isString(config.topologyService)) {
        switch (config.topologyService) {
          case TransportFactory.TopologyServices.Simple:
            topologyService = new SimpleTopologyService();
        }
      } else if (_.isObject(config.topologyService)) {
        topologyService = config.topologyService;
      }
      if (!_.isObject(config.channelProvider) && _.isString(config.channelProvider)) {
        switch (config.channelProvider) {
          case TransportFactory.ChannelFactories.WebStomp:
            channelProvider = new WebStompChannelProvider();
        }
      } else if (_.isObject(config.channelProvider)) {
        channelProvider = config.channelProvider;
      }
      switch (config.transportProvider) {
        case TransportFactory.TransportProviders.WebStomp:
          if (!_.isObject(topologyService)) {
            Logger.log.info("TransportFactory.getTransportProvider >> using default topology service");
          }
          if (!_.isObject(topologyService)) {
            topologyService = new SimpleTopologyService();
          }
          if (!_.isObject(channelProvider)) {
            Logger.log.info("TransportFactory.getTransportProvider >> using default channel provider");
          }
          if (!_.isObject(channelProvider)) {
            channelProvider = new WebStompChannelProvider();
          }
          config = {
            topologyService: topologyService,
            channelProvider: channelProvider
          };
          return new WebStompTransportProvider(config);
      }
    };

    return TransportFactory;

  })();
  return TransportFactory;
});
