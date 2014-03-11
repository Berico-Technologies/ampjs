define [
  './EnvelopeHeaderConstants'
  'underscore'
],
(EnvelopeHeaderConstants, _)->
  class EnvelopeHelper
    constructor:(@envelope)->
    flatten:(separator)-> JSON.stringify(@envelope.headers)
    getCorrelationId: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_CORRELATION_ID)
    getCreationTime: -> @envelope.getHeader(EnvelopeHeaderConstants.ENVELOPE_CREATION_TIME)
    getDigitalSignature: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_SIGNATURE)
    getEnvelope: -> @envelope
    getHeader:(key) -> @envelope.getHeader(key)
    getMessageId: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_ID)
    getMessagePattern: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN)
    getMessageTopic: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_TOPIC)
    getMessageType: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_TYPE)
    getPayload: -> @envelope.getPayload()
    getReciptTime: -> @envelope.getHeader(EnvelopeHeaderConstants.ENVELOPE_RECEIPT_TIME)
    getRpcTimeout: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC_TIMEOUT)
    getSenderIdentity: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_IDENTITY)
    getSenderAuthToken: -> @envelope.getHeader(EnvelopeHeaderConstants.SENDER_AUTH_TOKEN)
    getOriginatorIdentity: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_ORIGINATOR_IDENTITY)
    getOriginatorCredentials: -> @envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_ORIGINATOR_CREDENTIALS)
    getX509SenderPublicKeyHeader: -> @envelope.getHeader(EnvelopeHeaderConstants.X509_SENDER_PUBLIC_KEY_HEADER)
    getRsaEncryptedKeyHeader: -> @envelope.getHeader(EnvelopeHeaderConstants.RSA_ENCRYPTED_KEY_HEADER)
    getSymetricKeySalt: -> @envelope.getHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_SALT)
    getSymmetricKeyInitializationVector: -> @envelope.getHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_INITIALIZATION_VECTOR)
    getSymmetricKeyIterationCount:-> @envelope.getHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_ITERATION_COUNT)
    getSymmetricKeySize:-> @envelope.getHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_SIZE)
    getReplyToTopic:-> @envelope.getHeader(EnvelopeHeaderConstants.REPLY_TO_TOPIC)

    isPubSub: -> EnvelopeHeaderConstants.MESSAGE_PATTERN_PUBSUB == @getMessagePattern()
    isRequest: -> !(_.isString @getCorrelationId && @getCorrelationId.length > 0) && @isRpc
    isRpc: -> EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC == @getMessagePattern()

    setCorrelationId:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_CORRELATION_ID, input)
    setCreationTime:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.ENVELOPE_CREATION_TIME, input)
    setDigitalSignature:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_SIGNATURE, input)
    setHeader:(key, input) -> @envelope.setHeader(key, input)
    setMessageId:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_ID, input)
    setMessagePattern:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN, input)
    setMessageTopic:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_TOPIC, input)
    setMessageType:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_TYPE, input)
    setPayload:(input) -> @envelope.setPayload input
    setReciptTime:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.ENVELOPE_RECEIPT_TIME, input)
    setRpcTimeout:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC_TIMEOUT, input)
    setSenderIdentity:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_IDENTITY, input)
    setSenderAuthToken:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.SENDER_AUTH_TOKEN, input)
    setOriginatorIdentity:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_ORIGINATOR_IDENTITY, input)
    setOriginatorCredentials:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_ORIGINATOR_CREDENTIALS, input)
    setX509SenderPublicKeyHeader:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.X509_SENDER_PUBLIC_KEY_HEADER, input)
    setRsaEncryptedKeyHeader:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.RSA_ENCRYPTED_KEY_HEADER, input)
    setSymetricKeySalt:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_SALT, input)
    setSymmetricKeyInitializationVector:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_INITIALIZATION_VECTOR, input)
    setSymmetricKeyIterationCount:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_ITERATION_COUNT, input)
    setSymmetricKeySize:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.SYMMETRIC_KEY_SIZE, input)
    setReplyToTopic:(input) -> @envelope.setHeader(EnvelopeHeaderConstants.REPLY_TO_TOPIC, input)

  return EnvelopeHelper