define(['../../util/Logger', 'jquery'], function(Logger) {
  var RoutingInfoRetriever;

  RoutingInfoRetriever = (function() {
    function RoutingInfoRetriever(username, password, hostname, port, serviceUrlExpression, serializer) {
      this.username = username;
      this.password = password;
      this.hostname = hostname;
      this.port = port;
      this.serviceUrlExpression = serviceUrlExpression;
      this.serializer = serializer;
    }

    RoutingInfoRetriever.prototype.retrieveRoutingInfo = function(topic) {
      var deferred, req;

      Logger.log.info("RoutingInfoRetriever.retrieveRoutingInfo >> Getting routing info for topic: " + topic);
      deferred = $.Deferred();
      req = $.ajax({
        url: "http://" + this.username + ":" + this.password + "@" + this.hostname + ":" + this.port + this.serviceUrlExpression + "/" + topic + "?c=true",
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
