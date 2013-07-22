define(['../../util/Logger'], function(Logger) {
  var InboundEnvelopeProcessorCallback;
  InboundEnvelopeProcessorCallback = (function() {
    function InboundEnvelopeProcessorCallback(envelopeBus) {
      this.envelopeBus = envelopeBus;
    }

    InboundEnvelopeProcessorCallback.prototype.handleRecieve = function(dispatcher) {
      var env;
      Logger.log.info("InboundEnvelopeProcessorCallback.handleRecieve >> received a message");
      env = dispatcher.envelope;
      this.envelopeBus.processInbound(env);
      return dispatcher.dispatch(env);
    };

    return InboundEnvelopeProcessorCallback;

  })();
  return InboundEnvelopeProcessorCallback;
});
