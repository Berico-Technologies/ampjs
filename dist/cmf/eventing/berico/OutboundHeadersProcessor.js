define(['../../bus/berico/EnvelopeHelper', 'uuid', 'underscore', '../../util/Logger'], function(EnvelopeHelper, uuid, _, Logger) {
  var OutboundHeadersProcessor;

  OutboundHeadersProcessor = (function() {
    OutboundHeadersProcessor.prototype.userInfoRepo = null;

    function OutboundHeadersProcessor(userInfoRepo) {
      this.userInfoRepo = userInfoRepo;
    }

    OutboundHeadersProcessor.prototype.processOutbound = function(context) {
      var correlationId, env, messageId, messageTopic, messageType, senderIdentity;

      Logger.log.info("OutboundHeadersProcessor.processOutbound >> adding headers");
      env = new EnvelopeHelper(context.getEnvelope());
      messageId = _.isString(env.getMessageId()) ? env.getMessageId() : uuid.v4();
      env.setMessageId(messageId);
      correlationId = env.getCorrelationId();
      messageType = env.getMessageType();
      messageType = _.isString(messageType) ? messageType : this.getMessageType(context.getEvent());
      env.setMessageType(messageType);
      messageTopic = env.getMessageTopic();
      messageTopic = _.isString(messageTopic) ? messageTopic : this.getMessageTopic(context.getEvent());
      env.setMessageTopic(messageTopic);
      senderIdentity = env.getSenderIdentity();
      senderIdentity = _.isString(senderIdentity) ? senderIdentity : "unknown";
      return env.setSenderIdentity(senderIdentity);
    };

    OutboundHeadersProcessor.prototype.getMessageType = function(event) {
      var type;

      type = event.__proto__.constructor.name;
      Logger.log.info("OutboundHeadersProcessor.getMessageType >> inferring type as " + type);
      return type;
    };

    OutboundHeadersProcessor.prototype.getMessageTopic = function(event) {
      var type;

      type = event.__proto__.constructor.name;
      Logger.log.info("OutboundHeadersProcessor.getMessageTopic >> inferring topic as " + type);
      return type;
    };

    return OutboundHeadersProcessor;

  })();
  return OutboundHeadersProcessor;
});
