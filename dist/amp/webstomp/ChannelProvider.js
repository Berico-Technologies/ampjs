define(['stomp', '../util/Logger', 'sockjs', 'underscore', 'jquery', './topology/DefaultAuthenticationProvider'], function(Stomp, Logger, SockJS, _, $, DefaultAuthenticationProvider) {
  var ChannelProvider;
  ChannelProvider = (function() {
    ChannelProvider.DefaultConnectionStrategy = function(exchange) {
      return "https://" + exchange.hostName + ":" + exchange.port + exchange.vHost;
    };

    ChannelProvider.prototype.connectionPool = {};

    function ChannelProvider(config) {
      if (config == null) {
        config = {};
      }
      this.connectionStrategy = config.connectionStrategy, this.connectionFactory = config.connectionFactory, this.authenticationProvider = config.authenticationProvider;
      if (!_.isFunction(this.connectionStrategy)) {
        this.connectionStrategy = ChannelProvider.DefaultConnectionStrategy;
      }
      if (!_.isFunction(this.connectionFactory)) {
        this.connectionFactory = SockJS;
      }
      if (!_.isObject(this.authenticationProvider)) {
        this.authenticationProvider = new DefaultAuthenticationProvider();
      }
      Logger.log.info("ChannelProvider.ctor >> instantiated.");
    }

    ChannelProvider.prototype.getConnection = function(exchange) {
      var connection, connectionName, deferred,
        _this = this;
      deferred = $.Deferred();
      Logger.log.info("ChannelProvider.getConnection >> Getting exchange");
      connectionName = this.connectionStrategy(exchange);
      connection = this.connectionPool[connectionName];
      if (connection == null) {
        Logger.log.info("ChannelProvider.getConnection >> could not find existing connection");
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
      var _this = this;
      Logger.log.info("ChannelProvider._createConnection >> attempting to create a new connection");
      return this.authenticationProvider.getCredentials().then(function(credentials) {
        var client, password, username, ws;
        username = credentials.username, password = credentials.password;
        ws = new _this.connectionFactory(_this.connectionStrategy(exchange));
        client = Stomp.over(ws);
        client.heartbeat = {
          outgoing: 0,
          incoming: 0
        };
        client.connect(username, password, function() {
          Logger.log.info("ChannelProvider._createConnection >> successfully connected");
          return deferred.resolve(client, false);
        }, function(err) {
          var errorMessage;
          errorMessage = "ChannelProvider._createConnection >> " + err;
          Logger.log.error("ChannelProvider._createConnection >> unable to connect: " + err);
          deferred.reject(errorMessage);
          return Logger.log.error(errorMessage);
        });
        return deferred.promise();
      });
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
