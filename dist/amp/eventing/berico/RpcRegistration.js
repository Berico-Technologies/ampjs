var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../../bus/berico/EnvelopeHelper', 'jquery', './ProcessingContext', './EventRegistration', '../../util/Logger', '../../bus/berico/EnvelopeHeaderConstants'], function(EnvelopeHelper, $, ProcessingContext, EventRegistration, Logger, EnvelopeHeaderConstants) {
  var RpcRegistration;
  RpcRegistration = (function(_super) {
    __extends(RpcRegistration, _super);

    function RpcRegistration(config) {
      var expectedTopic, requestId;
      if (config == null) {
        config = {};
      }
      requestId = config.requestId, expectedTopic = config.expectedTopic, this.inboundChain = config.inboundChain;
      this.responseFilter = {
        filter: function(envelope) {
          return new EnvelopeHelper(envelope).getCorrelationId() === requestId;
        }
      };
      this.registrationInfo = {};
      this.registrationInfo[EnvelopeHeaderConstants.MESSAGE_TOPIC] = this.buildRpcTopic(expectedTopic, requestId);
      this.requestDeferred = $.Deferred();
    }

    RpcRegistration.prototype.buildRpcTopic = function(expectedTopic, requestId) {
      var topic;
      topic = "" + expectedTopic + "#" + requestId;
      Logger.log.info("RpcRegistration.buildRpcTopic >> rpc topic is " + topic);
      return topic;
    };

    RpcRegistration.prototype.getResponse = function() {
      return this.requestDeferred.promise();
    };

    RpcRegistration.prototype.handle = function(envelope) {
      var processorContext;
      Logger.log.info("RpcRegistration.handle >> received new envelope");
      processorContext = new ProcessingContext(envelope, envelope);
      if (this.processInbound(processorContext)) {
        return this.requestDeferred.resolve(processorContext.getEvent());
      }
    };

    return RpcRegistration;

  })(EventRegistration);
  return RpcRegistration;
});
