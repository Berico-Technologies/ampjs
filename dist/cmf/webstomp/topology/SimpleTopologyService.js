define(['uuid', '../../util/Logger', './RoutingInfo', './RouteInfo', './Exchange', 'underscore', '../../bus/berico/EnvelopeHeaderConstants'], function(uuid, Logger, RoutingInfo, RouteInfo, Exchange, _, EnvelopeHeaderConstants) {
  var SimpleTopologyService;

  SimpleTopologyService = (function() {
    function SimpleTopologyService(clientProfile, name, hostname, vhost, port) {
      this.clientProfile = _.isString(clientProfile) ? clientProfile : uuid.v4();
      this.name = _.isString(name) ? name : "cmf.simple.exchange";
      this.hostname = _.isString(hostname) ? hostname : "127.0.0.1";
      this.virtualHost = _.isString(vhost) ? vhost : "/stomp";
      this.port = _.isNumber(port) ? port : 15674;
      this.QUEUE_NUMBER = 0;
    }

    SimpleTopologyService.prototype.getRoutingInfo = function(headers) {
      var theOneExchange, theOneRoute, topic;

      topic = headers[EnvelopeHeaderConstants.MESSAGE_TOPIC];
      theOneExchange = new Exchange(this.name, this.hostname, this.virtualHost, this.port, topic, this.buildIdentifiableQueueName(topic), "direct", false, true, null);
      theOneRoute = new RouteInfo(theOneExchange, theOneExchange);
      return new RoutingInfo([theOneRoute]);
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
