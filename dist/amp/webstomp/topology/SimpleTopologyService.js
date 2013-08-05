define(['uuid', '../../util/Logger', './RoutingInfo', './RouteInfo', './Exchange', 'underscore', '../../bus/berico/EnvelopeHeaderConstants', 'jquery'], function(uuid, Logger, RoutingInfo, RouteInfo, Exchange, _, EnvelopeHeaderConstants, $) {
  var SimpleTopologyService;
  SimpleTopologyService = (function() {
    function SimpleTopologyService(config) {
      if (config == null) {
        config = {};
      }
      this.clientProfile = config.clientProfile, this.name = config.name, this.hostname = config.hostname, this.virtualHost = config.virtualHost, this.port = config.port, this.queue_number = config.queue_number;
      if (!_.isString(this.clientProfile)) {
        this.clientProfile = uuid.v4();
      }
      if (!_.isString(this.name)) {
        this.name = 'cmf.simple.exchange';
      }
      if (!_.isString(this.hostname)) {
        this.hostname = '127.0.0.1';
      }
      if (!_.isString(this.virtualHost)) {
        this.virtualHost = '/stomp';
      }
      if (!_.isNumber(this.port)) {
        this.port = 15678;
      }
      if (!_.isNumber(this.queue_number)) {
        this.queue_number = 0;
      }
    }

    SimpleTopologyService.prototype.getRoutingInfo = function(headers) {
      var deferred, theOneExchange, theOneRoute, topic;
      deferred = $.Deferred();
      topic = headers[EnvelopeHeaderConstants.MESSAGE_TOPIC];
      theOneExchange = new Exchange(this.name, this.hostname, this.virtualHost, this.port, topic, this.buildIdentifiableQueueName(topic), "direct", false, true, null);
      theOneRoute = new RouteInfo(theOneExchange, theOneExchange);
      this.createRoute(theOneExchange).then(function(data) {
        return deferred.resolve(new RoutingInfo([theOneRoute]));
      });
      return deferred.promise();
    };

    SimpleTopologyService.prototype.createRoute = function(exchange) {
      var deferred;
      deferred = $.Deferred();
      deferred.resolve(null);
      return deferred.promise();
    };

    SimpleTopologyService.prototype.buildIdentifiableQueueName = function(topic) {
      if (topic.indexOf("#") === -1) {
        return "" + this.clientProfile + "#" + (this.pad(++this.queue_number, 3, 0)) + "#" + topic;
      } else {
        return topic;
      }
    };

    SimpleTopologyService.prototype.pad = function(n, width, z) {
      z = z || '0';
      n = n + '';
      if (n.length >= width) {
        return n;
      } else {
        return new Array(width - n.length + 1).join(z) + n;
      }
    };

    SimpleTopologyService.prototype.dispose = function() {};

    return SimpleTopologyService;

  })();
  return SimpleTopologyService;
});
