define(['./ProcessingContext', '../../bus/Envelope', './EventRegistration', '../../util/Logger', 'jquery'], function(ProcessingContext, Envelope, EventRegistration, Logger, $) {
  var EventBus;
  EventBus = (function() {
    function EventBus(envelopeBus, inboundProcessors, outboundProcessors) {
      this.envelopeBus = envelopeBus;
      this.inboundProcessors = inboundProcessors != null ? inboundProcessors : [];
      this.outboundProcessors = outboundProcessors != null ? outboundProcessors : [];
    }

    EventBus.prototype.dispose = function() {
      return this.envelopeBus.dispose();
    };

    EventBus.prototype.finalize = function() {
      return this.dispose();
    };

    EventBus.prototype.processOutbound = function(event, envelope) {
      var context, deferred, looper, outboundProcessor, _i, _len, _ref;
      Logger.log.info("EventBus.processOutbound >> executing processors");
      context = new ProcessingContext(envelope, event);
      deferred = $.Deferred();
      looper = $.Deferred().resolve();
      _ref = this.outboundProcessors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        outboundProcessor = _ref[_i];
        looper = looper.then(function() {
          return outboundProcessor.processOutbound(context);
        });
      }
      looper.then(function() {
        Logger.log.info("EventBus.processOutbound >> all outbound processors executed");
        return deferred.resolve();
      });
      return deferred.promise();
    };

    EventBus.prototype.publish = function(event) {
      var envelope,
        _this = this;
      envelope = new Envelope();
      return this.processOutbound(event, envelope).then(function() {
        return _this.envelopeBus.send(envelope);
      });
    };

    EventBus.prototype.subscribe = function(eventHandler) {
      var registration;
      registration = new EventRegistration(eventHandler, this.inboundProcessors);
      return this.envelopeBus.register(registration);
    };

    return EventBus;

  })();
  return EventBus;
});
