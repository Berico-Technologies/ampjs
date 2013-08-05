define(['jquery', 'underscore', '../../util/Logger'], function($, _, Logger) {
  var DefaultAuthenticationProvider;
  DefaultAuthenticationProvider = (function() {
    DefaultAuthenticationProvider.prototype.username = null;

    DefaultAuthenticationProvider.prototype.password = null;

    function DefaultAuthenticationProvider(config) {
      if (config == null) {
        config = {};
      }
      this.hostname = config.hostname, this.port = config.port, this.serviceUrl = config.serviceUrl, this.connectionStrategy = config.connectionStrategy;
      if (!_.isString(this.hostname)) {
        this.hostname = 'localhost';
      }
      if (!_.isNumber(this.port)) {
        this.port = 15679;
      }
      if (!_.isString(this.serviceUrl)) {
        this.serviceUrl = '/anubis/identity/authenticate';
      }
      if (!_.isFunction(this.connectionStrategy)) {
        this.connectionStrategy = function() {
          return "https://" + this.hostname + ":" + this.port + this.serviceUrl;
        };
      }
    }

    DefaultAuthenticationProvider.prototype.getCredentials = function() {
      var deferred,
        _this = this;
      deferred = $.Deferred();
      if (_.isNull(this.username) || _.isNull(this.password)) {
        this._authenticate().then(function() {
          return deferred.resolve({
            username: _this.username,
            password: _this.password
          });
        });
      } else {
        deferred.resolve({
          username: this.username,
          password: this.password
        });
      }
      return deferred.promise();
    };

    DefaultAuthenticationProvider.prototype._authenticate = function() {
      var deferred, req,
        _this = this;
      deferred = $.Deferred();
      req = $.ajax({
        url: this.connectionStrategy(),
        dataType: 'jsonp'
      });
      req.done(function(data, textStatus, jqXHR) {
        Logger.log.info("DefaultAuthenticationProvider.authenticate >> successfully completed request");
        if (_.isObject(data)) {
          if (_.isString(data.identity)) {
            _this.username = data.identity;
          }
          if (_.isString(data.token)) {
            _this.password = data.token;
          }
          return deferred.resolve(data);
        } else {
          return deferred.reject();
        }
      });
      req.fail(function(jqXHR, textStatus, errorThrown) {
        Logger.log.error("DefaultAuthenticationProvider.authenticate >> failed complete request");
        return deferred.reject();
      });
      return deferred.promise();
    };

    return DefaultAuthenticationProvider;

  })();
  return DefaultAuthenticationProvider;
});
