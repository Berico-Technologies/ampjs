define(['../../bus/berico/EnvelopeHeaderConstants', './ProcessingContext', '../../util/Logger'], function(EnvelopeHeaderConstants, ProcessingContext, Logger) {
  var EventRegistration;
  EventRegistration = (function() {
    EventRegistration.prototype.filterPredicate = null;

    EventRegistration.prototype.registrationInfo = {};

    function EventRegistration(eventHandler, inboundChain) {
      this.eventHandler = eventHandler;
      this.inboundChain = inboundChain;
      this.registrationInfo[EnvelopeHeaderConstants.MESSAGE_TOPIC] = eventHandler.getEventType();
    }

    EventRegistration.prototype.handle = function(envelope) {
      var ev, processorContext;
      Logger.log.info("EventRegistration.handle >> received new envelope");
      ev = {};
      processorContext = new ProcessingContext(envelope, ev);
      if (this.processInbound(processorContext)) {
        return this.eventHandler.handle(processorContext.getEvent(), processorContext.getEnvelope().getHeaders());
      }
    };

    EventRegistration.prototype.processInbound = function(processorContext) {
      var processed, processor, _i, _len, _ref;
      Logger.log.info("EventRegistration.processInbound >> processing inbound queue");
      processed = true;
      _ref = this.inboundChain;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        processor = _ref[_i];
        if (!processor.processInbound(processorContext)) {
          processor = false;
        }
        if (!processor) {
          break;
        }
      }
      return processed;
    };

    EventRegistration.prototype.handleFailed = function(envelope, exception) {
      return eventHandler.handleFailed(envelope, exception);
    };

    return EventRegistration;

  })();
  return EventRegistration;
});
