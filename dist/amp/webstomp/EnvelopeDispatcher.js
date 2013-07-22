define(['underscore', '../util/Logger'], function(_, Logger) {
  var EnvelopeDispatcher;
  EnvelopeDispatcher = (function() {
    function EnvelopeDispatcher(registration, envelope, channel) {
      this.registration = registration;
      this.envelope = envelope;
      this.channel = channel;
    }

    EnvelopeDispatcher.prototype.dispatch = function(envelope) {
      Logger.log.info("EnvelopeDispatcher.dispatch >> dispatching envelope");
      if (!_.isObject(envelope)) {
        this.dispatch(this.envelope);
      }
      return this.registration.handle(envelope);
    };

    EnvelopeDispatcher.prototype.dispatchFailed = function(envelope, exception) {};

    return EnvelopeDispatcher;

  })();
  return EnvelopeDispatcher;
});
