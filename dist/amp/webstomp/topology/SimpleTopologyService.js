define(['uuid', '../../util/Logger', './RoutingInfo', './RouteInfo', './Exchange', 'underscore', '../../bus/berico/EnvelopeHeaderConstants', 'jquery'], function(uuid, Logger, RoutingInfo, RouteInfo, Exchange, _, EnvelopeHeaderConstants, $) {
  var SimpleTopologyService;

  SimpleTopologyService = (function() {
    function SimpleTopologyService(clientProfile, name, hostname, virtualHost, port, QUEUE_NUMBER) {
      this.clientProfile = clientProfile != null ? clientProfile : uuid.v4();
      this.name = name != null ? name : 'cmf.simple.exchange';
      this.hostname = hostname != null ? hostname : '127.0.0.1';
      this.virtualHost = virtualHost != null ? virtualHost : '/stomp';
      this.port = port != null ? port : 15674;
      this.QUEUE_NUMBER = QUEUE_NUMBER != null ? QUEUE_NUMBER : 0;
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
      return "" + this.clientProfile + "#" + (this.pad(++this.QUEUE_NUMBER, 3, 0)) + "#" + topic;
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
