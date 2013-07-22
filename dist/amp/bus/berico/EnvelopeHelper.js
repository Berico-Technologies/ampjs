define(['./EnvelopeHeaderConstants', 'underscore'], function(EnvelopeHeaderConstants, _) {
  var EnvelopeHelper;
  EnvelopeHelper = (function() {
    function EnvelopeHelper(envelope) {
      this.envelope = envelope;
    }

    EnvelopeHelper.prototype.flatten = function(separator) {
      return JSON.stringify(this.envelope.headers);
    };

    EnvelopeHelper.prototype.getCorrelationId = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_CORRELATION_ID);
    };

    EnvelopeHelper.prototype.getCreationTime = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.ENVELOPE_CREATION_TIME);
    };

    EnvelopeHelper.prototype.getDigitalSignature = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_SIGNATURE);
    };

    EnvelopeHelper.prototype.getEnvelope = function() {
      return this.envelope;
    };

    EnvelopeHelper.prototype.getHeader = function(key) {
      return this.envelope.getHeader(key);
    };

    EnvelopeHelper.prototype.getMessageId = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_ID);
    };

    EnvelopeHelper.prototype.getMessagePattern = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN);
    };

    EnvelopeHelper.prototype.getMessageTopic = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_TOPIC);
    };

    EnvelopeHelper.prototype.getMessageType = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_TYPE);
    };

    EnvelopeHelper.prototype.getPayload = function() {
      return this.envelope.getPayload();
    };

    EnvelopeHelper.prototype.getReciptTime = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.ENVELOPE_RECEIPT_TIME);
    };

    EnvelopeHelper.prototype.getRpcTimeout = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC_TIMEOUT);
    };

    EnvelopeHelper.prototype.getSenderIdentity = function() {
      return this.envelope.getHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_IDENTITY);
    };

    EnvelopeHelper.prototype.isPubSub = function() {
      return EnvelopeHeaderConstants.MESSAGE_PATTERN_PUBSUB === this.getMessagePattern;
    };

    EnvelopeHelper.prototype.isRequest = function() {
      return !(_.isString(this.getCorrelationId && this.getCorrelationId.length > 0)) && this.isRpc;
    };

    EnvelopeHelper.prototype.isRpc = function() {
      return EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC === this.getMessagePattern;
    };

    EnvelopeHelper.prototype.setCorrelationId = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_CORRELATION_ID, input);
    };

    EnvelopeHelper.prototype.setCreationTime = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.ENVELOPE_CREATION_TIME, input);
    };

    EnvelopeHelper.prototype.setDigitalSignature = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_SIGNATURE, input);
    };

    EnvelopeHelper.prototype.setHeader = function(key, input) {
      return this.envelope.setHeader(key, input);
    };

    EnvelopeHelper.prototype.setMessageId = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_ID, input);
    };

    EnvelopeHelper.prototype.setMessagePattern = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN, input);
    };

    EnvelopeHelper.prototype.setMessageTopic = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_TOPIC, input);
    };

    EnvelopeHelper.prototype.setMessageType = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_TYPE, input);
    };

    EnvelopeHelper.prototype.setPayload = function(input) {
      return this.envelope.setPayload(input);
    };

    EnvelopeHelper.prototype.setReciptTime = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.ENVELOPE_RECEIPT_TIME, input);
    };

    EnvelopeHelper.prototype.setRpcTimeout = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC_TIMEOUT, input);
    };

    EnvelopeHelper.prototype.setSenderIdentity = function(input) {
      return this.envelope.setHeader(EnvelopeHeaderConstants.MESSAGE_SENDER_IDENTITY, input);
    };

    return EnvelopeHelper;

  })();
  return EnvelopeHelper;
});
