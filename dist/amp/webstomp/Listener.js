define(['underscore', '../bus/Envelope', '../bus/berico/EnvelopeHelper', './EnvelopeDispatcher', 'jquery', '../util/Logger'], function(_, Envelope, EnvelopeHelper, EnvelopeDispatcher, $, Logger) {
  var Listener;
  Listener = (function() {
    Listener.prototype.envCallbacks = [];

    Listener.prototype.closeCallbacks = [];

    Listener.prototype.connectionErrorCallbacks = [];

    function Listener(registration, exchange) {
      this.registration = registration;
      this.exchange = exchange;
    }

    Listener.prototype.onEnvelopeReceived = function(callback) {
      return this.envCallbacks.push(callback);
    };

    Listener.prototype.onClose = function(callback) {
      return this.closeCallbacks.push(callback);
    };

    Listener.prototype.onConnectionError = function(callback) {
      return this.connectionErrorCallbacks.push(callback);
    };

    Listener.prototype.start = function(channel) {
      var deferred;
      this.channel = channel;
      deferred = $.Deferred();
      Logger.log.info("Listener.start >> subscribing to /queue/" + this.exchange.queueName);
      channel.subscribe("/amq/queue/" + this.exchange.queueName, _.bind(this.handleNextDelivery, this));
      deferred.resolve();
      return deferred.promise();
    };

    Listener.prototype.handleNextDelivery = function(result) {
      var envelopeHelper;
      Logger.log.info("Listener.handleNextDelivery >> received a message");
      envelopeHelper = this.createEnvelopeFromDeliveryResult(result);
      if (this.shouldRaiseEvent(this.registration.filterPredicate, envelopeHelper.getEnvelope())) {
        Logger.log.info("Listener.handleNextDelivery >> raising event from received message");
        return this.dispatchEnvelope(envelopeHelper.getEnvelope());
      }
    };

    Listener.prototype.dispatchEnvelope = function(envelope) {
      var dispatcher;
      dispatcher = new EnvelopeDispatcher(this.registration, envelope, this.channel);
      return this.raise_onEnvelopeRecievedEvent(dispatcher);
    };

    Listener.prototype.raise_onEnvelopeRecievedEvent = function(dispatcher) {
      var callback, _i, _len, _ref, _results;
      _ref = this.envCallbacks;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.handleRecieve(dispatcher));
      }
      return _results;
    };

    Listener.prototype.shouldRaiseEvent = function(filter, envelope) {
      if (_.isNull(filter) || !(_.isObject(filter))) {
        return true;
      } else {
        return filter.filter(envelope);
      }
    };

    Listener.prototype.createEnvelopeFromDeliveryResult = function(result) {
      var envelopeHelper, prop, _i, _len, _ref;
      envelopeHelper = new EnvelopeHelper(new Envelope());
      envelopeHelper.setReciptTime(new Date().getMilliseconds);
      envelopeHelper.setPayload(result.body);
      _ref = _.keys(result.headers);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prop = _ref[_i];
        envelopeHelper.setHeader(prop, result.headers[prop]);
      }
      return envelopeHelper;
    };

    Listener.prototype.dispose = function() {};

    return Listener;

  })();
  return Listener;
});
