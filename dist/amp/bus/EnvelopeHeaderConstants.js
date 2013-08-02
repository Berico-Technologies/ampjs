define([], function() {
  var EnvelopeHeaderConstants;
  EnvelopeHeaderConstants = (function() {
    function EnvelopeHeaderConstants() {}

    EnvelopeHeaderConstants.ENVELOPE_CREATION_TIME = "cmf.bus.envelope.creation";

    EnvelopeHeaderConstants.ENVELOPE_RECEIPT_TIME = "cmf.bus.envelope.receipt";

    EnvelopeHeaderConstants.MESSAGE_CORRELATION_ID = "cmf.bus.message.correlation_id";

    EnvelopeHeaderConstants.MESSAGE_ID = "cmf.bus.message.id";

    EnvelopeHeaderConstants.MESSAGE_PATTERN = "cmf.bus.message.pattern";

    EnvelopeHeaderConstants.MESSAGE_PATTERN_PUBSUB = "cmf.bus.message.pattern#pub_sub";

    EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC = "cmf.bus.message.pattern#rpc";

    EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC_TIMEOUT = "cmf.bus.message.pattern#rpc.timeout";

    EnvelopeHeaderConstants.MESSAGE_SENDER_IDENTITY = "cmf.bus.message.sender_identity";

    EnvelopeHeaderConstants.MESSAGE_SENDER_SIGNATURE = "cmf.bus.message.sender_signature";

    EnvelopeHeaderConstants.MESSAGE_TOPIC = "cmf.bus.message.topic";

    EnvelopeHeaderConstants.MESSAGE_TYPE = "cmf.bus.message.type";

    return EnvelopeHeaderConstants;

  })();
  return EnvelopeHeaderConstants;
});
