define(['../../util/Logger', 'LRUCache', 'underscore', '../../bus/berico/EnvelopeHeaderConstants', 'jquery'], function(Logger, LRUCache, _, EnvelopeHeaderConstants, $) {
  var GlobalTopologyService;
  GlobalTopologyService = (function() {
    GlobalTopologyService.CACHE_EXPIRY_TIME_IN_MS = 1000000;

    GlobalTopologyService.prototype.routingInfoCache = {};

    GlobalTopologyService.prototype.fallbackProvider = null;

    function GlobalTopologyService(config) {
      var cacheExpiryTime;
      if (config == null) {
        config = {};
      }
      this.routingInfoRetriever = config.routingInfoRetriever, cacheExpiryTime = config.cacheExpiryTime, this.fallbackProvider = config.fallbackProvider, this.exchangeOverrides = config.exchangeOverrides;
      if (!_.isObject(this.exchangeOverrides)) {
        this.exchangeOverrides = {
          port: 15678,
          vHost: '/stomp'
        };
      }
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
      var override, route, value, _i, _len, _ref, _results;
      _ref = routingInfo.routes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        route = _ref[_i];
        _results.push((function() {
          var _ref1, _results1;
          _ref1 = this.exchangeOverrides;
          _results1 = [];
          for (override in _ref1) {
            value = _ref1[override];
            route.consumerExchange[override] = value;
            _results1.push(route.producerExchange[override] = value);
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return GlobalTopologyService;

  })();
  return GlobalTopologyService;
});
