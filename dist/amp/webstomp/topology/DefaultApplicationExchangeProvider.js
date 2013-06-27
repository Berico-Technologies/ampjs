var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./SimpleTopologyService', '../../bus/berico/EnvelopeHeaderConstants', '../../util/Logger'], function(SimpleTopoologyService, EnvelopeHeaderConstants, Logger) {
  var DefaultApplicationExchangeProvider;

  DefaultApplicationExchangeProvider = (function(_super) {
    __extends(DefaultApplicationExchangeProvider, _super);

    function DefaultApplicationExchangeProvider(managementHostname, managementPort, managementServiceUrl, clientProfile, name, hostname, vhost, port) {
      this.managementHostname = managementHostname;
      this.managementPort = managementPort;
      this.managementServiceUrl = managementServiceUrl;
      DefaultApplicationExchangeProvider.__super__.constructor.call(this, clientProfile, name, hostname, vhost, port);
    }

    DefaultApplicationExchangeProvider.prototype.getFallbackRoute = function(topic) {
      var headers;

      headers = [];
      headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = topic;
      return this.getRoutingInfo(headers);
    };

    DefaultApplicationExchangeProvider.prototype.createRoute = function(exchange) {
      var deferred, req;

      deferred = $.Deferred();
      req = $.ajax({
        url: "http://" + this.managementHostname + ":" + this.managementPort + this.managementServiceUrl,
        dataType: 'jsonp',
        data: {
          data: JSON.stringify(exchange)
        }
      });
      req.done(function(data, textStatus, jqXHR) {
        Logger.log.info("DefaultApplicationExchangeProvider.createRoute >> created route");
        return deferred.resolve(data);
      });
      req.fail(function(jqXHR, textStatus, errorThrown) {
        Logger.log.error("DefaultApplicationExchangeProvider.createRoute >> failed to create route");
        return deferred.reject();
      });
      return deferred.promise();
    };

    return DefaultApplicationExchangeProvider;

  })(SimpleTopoologyService);
  return DefaultApplicationExchangeProvider;
});
