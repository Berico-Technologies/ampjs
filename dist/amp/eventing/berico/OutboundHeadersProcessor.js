define(['../../bus/berico/EnvelopeHelper', 'uuid', 'underscore', '../../util/Logger', '../../webstomp/topology/DefaultAuthenticationProvider', 'jquery'], function(EnvelopeHelper, uuid, _, Logger, DefaultAuthenticationProvider, $) {
  var OutboundHeadersProcessor;
  OutboundHeadersProcessor = (function() {
    OutboundHeadersProcessor.prototype.userInfoRepo = null;

    function OutboundHeadersProcessor(config) {
      if (config == null) {
        config = {};
      }
      this.authenticationProvider = config.authenticationProvider;
      if (!_.isObject(this.authenticationProvider)) {
        this.authenticationProvider = new DefaultAuthenticationProvider();
      }
    }

    OutboundHeadersProcessor.prototype.processOutbound = function(context) {
      var correlationId, deferred, env, messageId, messageTopic, messageType, outboundDeferreds;
      deferred = $.Deferred();
      outboundDeferreds = [];
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
      outboundDeferreds.push(this.getUsername(env.getSenderIdentity()).then(function(username) {
        return env.setSenderIdentity(username);
      }));
      $.when.apply($, outboundDeferreds).done(function() {
        return deferred.resolve();
      });
      return deferred.promise();
    };

    OutboundHeadersProcessor.prototype.getUsername = function(username) {
      var deferred;
      deferred = $.Deferred();
      if (_.isString(username)) {
        Logger.log.info("OutboundHeadersProcessor.getUsername >> using username from envelope: " + username);
        deferred.resolve(username);
      } else {
        this.authenticationProvider.getCredentials().then(function(data) {
          Logger.log.info("OutboundHeadersProcessor.getUsername >> using username from authenticationProvider: " + data.username);
          return deferred.resolve(data.username);
        });
      }
      return deferred.promise();
    };

    OutboundHeadersProcessor.prototype.getMessageType = function(event) {
      var type;
      type = Object.getPrototypeOf(event).constructor.name;
      Logger.log.info("OutboundHeadersProcessor.getMessageType >> inferring type as " + type);
      return type;
    };

    OutboundHeadersProcessor.prototype.getMessageTopic = function(event) {
      var type;
      type = Object.getPrototypeOf(event).constructor.name;
      Logger.log.info("OutboundHeadersProcessor.getMessageTopic >> inferring topic as " + type);
      return type;
    };

    return OutboundHeadersProcessor;

  })();
  return OutboundHeadersProcessor;
});
