define(['../../util/Logger', 'LRUCache', 'underscore', '../../bus/berico/EnvelopeHeaderConstants', 'jquery'], function(Logger, LRUCache, _, EnvelopeHeaderConstants, $) {
  var GlobalTopologyService;

  GlobalTopologyService = (function() {
    GlobalTopologyService.CACHE_EXPIRY_TIME_IN_MS = 1000000;

    GlobalTopologyService.WEBSTOMP_PORT_OVERRIDE = 15674;

    GlobalTopologyService.WEBSTOMP_VHOST_OVERRIDE = "/stomp";

    GlobalTopologyService.prototype.routingInfoCache = {};

    GlobalTopologyService.prototype.fallbackProvider = null;

    function GlobalTopologyService(routingInfoRetriever, cacheExpiryTime, fallbackProvider) {
      this.routingInfoRetriever = routingInfoRetriever;
      this.fallbackProvider = fallbackProvider;
      this.routingInfoCache = new LRUCache({
        maxAge: _.isNumber(cacheExpiryTime) ? cacheExpiryTime : GlobalTopologyService.CACHE_EXPIRY_TIME_IN_MS
      });
    }

    GlobalTopologyService.prototype.getRoutingInfo = function(routingHints) {
      var deferred, routingInfo, topic,
        _this = this;

      deferred = $.Deferred();
      topic = routingHints[EnvelopeHeaderConstants.MESSAGE_TOPIC];
      Logger.log.info("GlobalTopologyService.getRoutingInfo>> Getting routing info for topic: " + topic);
      routingInfo = this.routingInfoCache.get(topic);
      if (_.isUndefined(routingInfo)) {
        Logger.log.info("GlobalTopologyService.getRoutingInfo>> route not in cache, attempting external lookup");
        this.routingInfoRetriever.retrieveRoutingInfo(topic).then(function(data) {
          if (_.has(data, 'routes') && _.size(data.routes) > 0) {
            Logger.log.info("GlobalTopologyService.getRoutingInfo>> Successfully retrieved " + (_.size(data.routes)) + " GTS routes");
            _this._fixExhangeInformation(data);
            _this.routingInfoCache.set(topic, data);
            return deferred.resolve(data);
          } else {
            Logger.log.info("GlobalTopologyService.getRoutingInfo>> no route in GTS: using fallback route");
            return _this.fallbackProvider.getFallbackRoute(topic).then(function(data) {
              return deferred.resolve(data);
            });
          }
        });
      } else {
        Logger.log.info("GlobalTopologyService.getRoutingInfo>> cache hit, returning route without lookup");
        deferred.resolve(routingInfo);
      }
      return deferred.promise();
    };

    GlobalTopologyService.prototype._fixExhangeInformation = function(routingInfo) {
      var route, _i, _len, _ref, _results;

      _ref = routingInfo.routes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        route = _ref[_i];
        route.consumerExchange.port = GlobalTopologyService.WEBSTOMP_PORT_OVERRIDE;
        route.consumerExchange.vHost = GlobalTopologyService.WEBSTOMP_VHOST_OVERRIDE;
        route.producerExchange.port = GlobalTopologyService.WEBSTOMP_PORT_OVERRIDE;
        _results.push(route.producerExchange.vHost = GlobalTopologyService.WEBSTOMP_VHOST_OVERRIDE);
      }
      return _results;
    };

    return GlobalTopologyService;

  })();
  return GlobalTopologyService;
});
