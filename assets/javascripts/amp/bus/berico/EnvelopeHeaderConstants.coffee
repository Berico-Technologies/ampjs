define [], ->
  class EnvelopeHeaderConstants
    @ENVELOPE_CREATION_TIME = "cmf.bus.envelope.creation"
    @ENVELOPE_RECEIPT_TIME = "cmf.bus.envelope.receipt"
    @MESSAGE_CORRELATION_ID = "cmf.bus.message.correlation_id"
    @MESSAGE_ID = "cmf.bus.message.id"
    @MESSAGE_PATTERN = "cmf.bus.message.pattern"
    @MESSAGE_PATTERN_PUBSUB = "cmf.bus.message.pattern#pub_sub"
    @MESSAGE_PATTERN_RPC = "cmf.bus.message.pattern#rpc"
    @MESSAGE_PATTERN_RPC_TIMEOUT = "cmf.bus.message.pattern#rpc.timeout"
    @MESSAGE_SENDER_IDENTITY = "cmf.bus.message.sender_identity"
    @MESSAGE_SENDER_SIGNATURE = "cmf.bus.message.sender_signature"
    @MESSAGE_TOPIC = "cmf.bus.message.topic"
    @MESSAGE_TYPE = "cmf.bus.message.type"
    @SENDER_AUTH_TOKEN: "SENDER_AUTH_TOKEN"
    @REPLY_TO_TOPIC: "cmf.bus.encryption.reply_to_topic"
    @MESSAGE_ORIGINATOR_IDENTITY = "cmf.bus.message.originator.identity"
    @MESSAGE_ORIGINATOR_CREDENTIALS = "cmf.bus.message.originator.credentials"

    @X509_SENDER_PUBLIC_KEY_HEADER = "cmf.bus.encryption.sender_public_key"
    @RSA_ENCRYPTED_KEY_HEADER = "cmf.bus.encryption.rsa_encrypted_secret_key"
    @SYMMETRIC_KEY_SALT = "cmf.bus.encryption.symmetric_key_salt"
    @SYMMETRIC_KEY_INITIALIZATION_VECTOR = "cmf.bus.encryption.symmetric_key_iv"
    @SYMMETRIC_KEY_ITERATION_COUNT = "cmf.bus.encryption.symmetric_key_count"
    @SYMMETRIC_KEY_SIZE = "cmf.bus.encryption.symmetric_key_size"

  return EnvelopeHeaderConstants