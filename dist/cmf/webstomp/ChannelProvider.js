define(['stomp', '../util/Logger', 'sockjs', 'underscore', 'jquery'], function(Stomp, Logger, SockJS, _, $) {
  var ChannelProvider;

  ChannelProvider = (function() {
    ChannelProvider.DefaultConnectionStrategy = function(exchange) {
      return "http://" + exchange.hostName + ":" + exchange.port + exchange.vHost;
    };

    function ChannelProvider(config) {
      var _ref;

      config = config != null ? config : {};
      this.username = _.isString(config.username) ? config.username : "guest";
      this.password = _.isString(config.password) ? config.password : "guest";
      this.connectionPool = {};
      this.connectionStrategy = (_ref = config.connectionStrategy) != null ? _ref : ChannelProvider.DefaultConnectionStrategy;
      Logger.log.info("ChannelProvider.ctor >> instantiated.");
      this.connectionFactory = _.isFunction(config.connectionFactory) ? config.connectionFactory : SockJS;
      if (!_.isFunction(config.connectionFactory)) {
        Logger.log.info("ChannelProvider.ctor >> using default connection factory");
      }
    }

    ChannelProvider.prototype.getConnection = function(exchange) {
      var connection, connectionName, deferred,
        _this = this;

      deferred = $.Deferred();
      Logger.log.info("ChannelProvider.getConnection >> Getting exchange");
      connectionName = this.connectionStrategy(exchange);
      connection = this.connectionPool[connectionName];
      if (connection == null) {
        Logger.log.info("ChannelProvider.getConnection >> creating new connection");
        this._createConnection(exchange, deferred);
        deferred.then(function(connection) {
          return _this.connectionPool[connectionName] = connection;
        });
      } else {
        Logger.log.info("ChannelProvider.getConnection >> returning existing connection");
        deferred.resolve(connection, true);
      }
      return deferred.promise();
    };

    ChannelProvider.prototype.removeConnection = function(exchange) {
      var connection, connectionName, deferred,
        _this = this;

      deferred = $.Deferred();
      Logger.log.info("ConnectionFactory.removeConnection >> Removing connection");
      connectionName = this.connectionStrategy(exchange);
      connection = this.connectionPool[connectionName];
      if (connection != null) {
        return connection.disconnect(function() {
          delete _this.connectionPool[connectionName];
          return deferred.resolve(true);
        });
      } else {
        return deferred.reject(false);
      }
    };

    ChannelProvider.prototype._createConnection = function(exchange, deferred) {
      var client, ws;

      Logger.log.info("ChannelProvider._createConnection >> creating new connection");
      ws = new this.connectionFactory(this.connectionStrategy(exchange));
      client = Stomp.over(ws);
      client.heartbeat = {
        outgoing: 0,
        incoming: 0
      };
      client.connect(this.username, this.password, function() {
        return deferred.resolve(client, false);
      }, function(err) {
        var errorMessage;

        errorMessage = "ChannelProvider._createConnection >> " + err;
        deferred.reject(errorMessage);
        return Logger.log.error(errorMessage);
      });
      return deferred.promise();
    };

    ChannelProvider.prototype.dispose = function() {
      var connection, connectionDeferred, disposeDeferred, disposeDeferredCollection, _i, _len, _ref;

      Logger.log.info("ChannelProvider.dispose >> clearing connections");
      disposeDeferred = $.Deferred();
      disposeDeferredCollection = [];
      _ref = this.connectionPool;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        connection = _ref[_i];
        connectionDeferred = $.Deferred();
        disposeDeferredCollection.push(connectionDeferred);
        connection.disconnect(function() {
          return connectionDeferred.resolve();
        });
      }
      $.when.apply($, disposeDeferredCollection).done(function() {
        return disposeDeferred.resolve();
      });
      return disposeDeferred.promise();
    };

    return ChannelProvider;

  })();
  return ChannelProvider;
});
