define(['./Listener', 'underscore', 'jquery', '../util/Logger'], function(Listener, _, $, Logger) {
  var TransportProvider;
  TransportProvider = (function() {
    TransportProvider.prototype.listeners = {};

    TransportProvider.prototype.envCallbacks = [];

    function TransportProvider(config) {
      var _ref, _ref1;
      config = config != null ? config : {};
      this.topologyService = (_ref = config.topologyService) != null ? _ref : {};
      this.channelProvider = (_ref1 = config.channelProvider) != null ? _ref1 : {};
    }

    TransportProvider.prototype.register = function(registration) {
      var deferred, pendingListeners,
        _this = this;
      Logger.log.info("TransportProvider.register >> registering new connection");
      deferred = $.Deferred();
      pendingListeners = [];
      this.topologyService.getRoutingInfo(registration.registrationInfo).then(function(routing) {
        var exchange, exchanges, listenerDeferred, _i, _len;
        exchanges = _.pluck(routing.routes, 'consumerExchange');
        for (_i = 0, _len = exchanges.length; _i < _len; _i++) {
          exchange = exchanges[_i];
          listenerDeferred = $.Deferred();
          pendingListeners.push(listenerDeferred);
          _this._createListener(registration, exchange).then(function(listener) {
            listenerDeferred.resolve();
            return _this.listeners[registration] = listener;
          });
        }
        return $.when.apply($, pendingListeners).done(function() {
          Logger.log.info("TransportProvider.register >> all listeners have been created");
          return deferred.resolve();
        });
      });
      return deferred.promise();
    };

    TransportProvider.prototype._createListener = function(registration, exchange) {
      var deferred,
        _this = this;
      deferred = $.Deferred();
      this.channelProvider.getConnection(exchange).then(function(connection) {
        var listener;
        listener = _this._getListener(registration, exchange);
        listener.onEnvelopeReceived({
          handleRecieve: function(dispatcher) {
            Logger.log.info("TransportProvider._createListener >> handleRecieve called");
            return _this.raise_onEnvelopeRecievedEvent(dispatcher);
          }
        });
        listener.onClose({
          onClose: function(registration) {
            return delete _this.listeners[registration];
          }
        });
        return listener.start(connection).then(function() {
          Logger.log.info("TransportProvider._createListener >> listener started");
          return deferred.resolve(listener);
        });
      });
      return deferred.promise();
    };

    TransportProvider.prototype._getListener = function(registration, exchange) {
      return new Listener(registration, exchange);
    };

    TransportProvider.prototype.send = function(envelope) {
      var deferred, pendingExchanges,
        _this = this;
      deferred = $.Deferred();
      pendingExchanges = [];
      this.topologyService.getRoutingInfo(envelope.getHeaders()).then(function(routing) {
        var exchange, exchangeDeferred, exchanges, _i, _len;
        exchanges = _.pluck(routing.routes, 'producerExchange');
        for (_i = 0, _len = exchanges.length; _i < _len; _i++) {
          exchange = exchanges[_i];
          exchangeDeferred = $.Deferred();
          pendingExchanges.push(exchangeDeferred);
          _this.channelProvider.getConnection(exchange).then(function(connection, existing) {
            var entry, headers, newHeaders;
            newHeaders = {};
            headers = envelope.getHeaders();
            for (entry in headers) {
              newHeaders[entry] = headers[entry];
            }
            Logger.log.info("TransportProvider.send >> sending message to /exchange/" + exchange.name + "/" + exchange.routingKey);
            exchangeDeferred.resolve();
            return connection.send("/exchange/" + exchange.name + "/" + exchange.routingKey, newHeaders, envelope.getPayload());
          });
        }
        return $.when.apply($, pendingExchanges).done(function() {
          return deferred.resolve();
        });
      });
      return deferred.promise();
    };

    TransportProvider.prototype.unregister = function(registration) {
      return delete this.listeners[registration];
    };

    TransportProvider.prototype.onEnvelopeRecieved = function(callback) {
      return this.envCallbacks.push(callback);
    };

    TransportProvider.prototype.raise_onEnvelopeRecievedEvent = function(dispatcher) {
      var callback, _i, _len, _ref, _results;
      _ref = this.envCallbacks;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.handleRecieve(dispatcher));
      }
      return _results;
    };

    TransportProvider.prototype.dispose = function() {
      var deferred, listener, pendingCleanups, registration, _ref;
      deferred = $.Deferred();
      pendingCleanups = [];
      pendingCleanups.push(this.channelProvider.dispose());
      pendingCleanups.push(this.topologyService.dispose());
      _ref = this.listeners;
      for (registration in _ref) {
        listener = _ref[registration];
        pendingCleanups.push(listener.dispose());
      }
      $.when.apply($, pendingCleanups).done(function() {
        return deferred.resolve();
      });
      return deferred.promise();
    };

    return TransportProvider;

  })();
  return TransportProvider;
});
