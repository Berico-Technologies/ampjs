var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./SimpleTopologyService', '../../bus/berico/EnvelopeHeaderConstants', '../../util/Logger'], function(SimpleTopoologyService, EnvelopeHeaderConstants, Logger) {
  var DefaultApplicationExchangeProvider;
  DefaultApplicationExchangeProvider = (function(_super) {
    __extends(DefaultApplicationExchangeProvider, _super);

    function DefaultApplicationExchangeProvider(config) {
      var clientProfile, exchangeHostname, exchangeName, exchangePort, exchangeVhost;
      if (config == null) {
        config = {};
      }
      this.managementHostname = config.managementHostname, this.managementPort = config.managementPort, this.managementServiceUrl = config.managementServiceUrl, this.connectionStrategy = config.connectionStrategy, clientProfile = config.clientProfile, exchangeName = config.exchangeName, exchangeHostname = config.exchangeHostname, exchangeVhost = config.exchangeVhost, exchangePort = config.exchangePort;
      if (!_.isString(this.managementHostname)) {
        this.managementHostname = 'localhost';
      }
      if (!_.isNumber(this.managementPort)) {
        this.managementPort = 15677;
      }
      if (!_.isString(this.managementServiceUrl)) {
        this.managementServiceUrl = '/service/fallbackRouting/routeCreator';
      }
      if (!_.isFunction(this.connectionStrategy)) {
        this.connectionStrategy = function() {
          return "https://" + this.managementHostname + ":" + this.managementPort + this.managementServiceUrl;
        };
      }
      DefaultApplicationExchangeProvider.__super__.constructor.call(this, {
        clientProfile: clientProfile,
        name: exchangeName,
        hostname: exchangeHostname,
        vhost: exchangeVhost,
        port: exchangePort
      });
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
        url: this.connectionStrategy(),
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
