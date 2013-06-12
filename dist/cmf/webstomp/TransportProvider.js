define(['./Listener', 'underscore', 'jquery', '../util/Logger'], function(Listener, _, $, Logger) {
  var TransportProvider;

  TransportProvider = (function() {
    TransportProvider.prototype.listeners = {};

    TransportProvider.prototype.envCallbacks = [];

    TransportProvider.prototype.managementUrl = 'http://localhost:8080/rabbit/declareExchange';

    function TransportProvider(config) {
      var _ref, _ref1;

      config = config != null ? config : {};
      this.topologyService = (_ref = config.topologyService) != null ? _ref : {};
      this.channelProvider = (_ref1 = config.channelProvider) != null ? _ref1 : {};
    }

    TransportProvider.prototype.register = function(registration) {
      var deferred, exchange, exchanges, listenerDeferred, pendingListeners, routing, _i, _len,
        _this = this;

      Logger.log.info("TransportProvider.register >> registering new connection");
      deferred = $.Deferred();
      pendingListeners = [];
      routing = this.topologyService.getRoutingInfo(registration.registrationInfo);
      exchanges = _.pluck(routing.routes, 'consumerExchange');
      for (_i = 0, _len = exchanges.length; _i < _len; _i++) {
        exchange = exchanges[_i];
        listenerDeferred = $.Deferred();
        pendingListeners.push(listenerDeferred);
        this._createListener(registration, exchange).then(function(listener) {
          listenerDeferred.resolve();
          return _this.listeners[registration] = listener;
        });
      }
      $.when.apply($, pendingListeners).done(function() {
        Logger.log.info("TransportProvider.register >> all listeners have been created");
        return deferred.resolve();
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
      var deferred, exchange, exchangeDeferred, exchanges, pendingExchanges, routing, _i, _len,
        _this = this;

      deferred = $.Deferred();
      pendingExchanges = [];
      routing = this.topologyService.getRoutingInfo(envelope.getHeaders());
      exchanges = _.pluck(routing.routes, 'producerExchange');
      for (_i = 0, _len = exchanges.length; _i < _len; _i++) {
        exchange = exchanges[_i];
        exchangeDeferred = $.Deferred();
        pendingExchanges.push(exchangeDeferred);
        this.channelProvider.getConnection(exchange).then(function(connection, existing) {
          var entry, headers, newHeaders, req;

          newHeaders = {};
          headers = envelope.getHeaders;
          for (entry in headers) {
            newHeaders[entry] = headers[entry];
          }
          Logger.log.info("TransportProvider.send >> declaring exchange " + exchange.name);
          req = $.ajax({
            url: _this.managementUrl,
            type: "GET",
            dataType: 'jsonp',
            data: {
              data: JSON.stringify({
                exchangeName: exchange.name,
                exchangeType: exchange.exchangeType,
                exchangeIsDurable: exchange.isDurable,
                exchangeIsAutoDelete: exchange.autoDelete,
                exchangeArguments: exchange["arguments"]
              })
            }
          });
          req.done(function(data, textStatus, jqXHR) {
            Logger.log.info("TransportProvider.send >> sending message to /exchange/" + exchange.name + "/" + exchange.routingKey);
            exchangeDeferred.resolve();
            return connection.send("/exchange/" + exchange.name + "/" + exchange.routingKey, newHeaders, envelope.getPayload());
          });
          return req.fail(function(jqXHR, textStatus, errorThrown) {
            Logger.log.error("TransportProvider.send >> failed to create exchange");
            return exchangeDeferred.reject();
          });
        });
      }
      $.when.apply($, pendingExchanges).done(function() {
        return deferred.resolve();
      });
      return deferred.promise();
    };

    TransportProvider.prototype.unregister = function(registration) {
      return delete listeners[registration];
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
