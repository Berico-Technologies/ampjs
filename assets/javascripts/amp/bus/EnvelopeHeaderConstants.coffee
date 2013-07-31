define [], ()->
  class EnvelopeHeaderConstants
    @ENVELOPE_CREATION_TIME: "cmf.bus.envelope.creation"
    @ENVELOPE_RECEIPT_TIME: "cmf.bus.envelope.receipt"
    @MESSAGE_CORRELATION_ID: "cmf.bus.message.correlation_id"
    @MESSAGE_ID: "cmf.bus.message.id"
    @MESSAGE_PATTERN: "cmf.bus.message.pattern"
    @MESSAGE_PATTERN_PUBSUB: "cmf.bus.message.pattern#pub_sub"
    @MESSAGE_PATTERN_RPC: "cmf.bus.message.pattern#rpc"
    @MESSAGE_PATTERN_RPC_TIMEOUT: "cmf.bus.message.pattern#rpc.timeout"
    @MESSAGE_SENDER_IDENTITY: "cmf.bus.message.sender_identity"
    @MESSAGE_SENDER_SIGNATURE: "cmf.bus.message.sender_signature"
    @MESSAGE_TOPIC: "cmf.bus.message.topic"
    @MESSAGE_TYPE: "cmf.bus.message.type"
  return EnvelopeHeaderConstants