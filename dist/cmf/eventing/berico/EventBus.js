define(['./ProcessingContext', '../../bus/Envelope', './EventRegistration', '../../util/Logger'], function(ProcessingContext, Envelope, EventRegistration, Logger) {
  var EventBus;

  EventBus = (function() {
    function EventBus(envelopeBus, inboundProcessors, outboundProcessors) {
      this.envelopeBus = envelopeBus;
      this.inboundProcessors = _.isArray(inboundProcessors) ? inboundProcessors : this.inboundProcessors;
      this.outboundProcessors = _.isArray(outboundProcessors) ? outboundProcessors : this.outboundProcessors;
    }

    EventBus.prototype.dispose = function() {
      return this.envelopeBus.dispose();
    };

    EventBus.prototype.finalize = function() {
      return this.dispose();
    };

    EventBus.prototype.processOutbound = function(event, envelope) {
      var context, outboundProcessor, _i, _len, _ref, _results;

      Logger.log.info("EventBus.processOutbound >> executing processors");
      context = new ProcessingContext(envelope, event);
      _ref = this.outboundProcessors;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        outboundProcessor = _ref[_i];
        _results.push(outboundProcessor.processOutbound(context));
      }
      return _results;
    };

    EventBus.prototype.publish = function(event) {
      var envelope;

      envelope = new Envelope();
      this.processOutbound(event, envelope);
      return this.envelopeBus.send(envelope);
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
