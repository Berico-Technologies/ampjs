define(['../../util/Logger', 'jquery'], function(Logger) {
  var RoutingInfoRetriever;
  RoutingInfoRetriever = (function() {
    function RoutingInfoRetriever(config) {
      if (config == null) {
        config = {};
      }
      this.hostname = config.hostname, this.port = config.port, this.serviceUrlExpression = config.serviceUrlExpression, this.connectionStrategy = config.connectionStrategy;
      if (!_.isString(this.hostname)) {
        this.hostname = '127.0.0.1';
      }
      if (!_.isNumber(this.port)) {
        this.port = 15677;
      }
      if (!_.isString(this.serviceUrlExpression)) {
        this.serviceUrlExpression = "/service/topology/get-routing-info";
      }
      if (!_.isFunction(this.connectionStrategy)) {
        this.connectionStrategy = function(topic) {
          return "https://" + this.hostname + ":" + this.port + this.serviceUrlExpression + "/" + topic + "?c=true";
        };
      }
    }

    RoutingInfoRetriever.prototype.retrieveRoutingInfo = function(topic) {
      var deferred, req;
      Logger.log.info("RoutingInfoRetriever.retrieveRoutingInfo >> Getting routing info for topic: " + topic);
      deferred = $.Deferred();
      req = $.ajax({
        url: this.connectionStrategy(topic),
        dataType: 'jsonp'
      });
      req.done(function(data, textStatus, jqXHR) {
        Logger.log.info("RoutingInfoRetriever.retrieveRoutingInfo >> retrieved topic info");
        return deferred.resolve(data);
      });
      req.fail(function(jqXHR, textStatus, errorThrown) {
        Logger.log.error("RoutingInfoRetriever.retrieveRoutingInfo >> failed to retrieve topic info");
        return deferred.reject();
      });
      return deferred.promise();
    };

    return RoutingInfoRetriever;

  })();
  return RoutingInfoRetriever;
});
