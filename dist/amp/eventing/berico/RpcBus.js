var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./EventBus', '../../util/Logger', './ProcessingContext', 'uuid', '../../bus/Envelope', '../../bus/berico/EnvelopeHelper', '../../bus/EnvelopeHeaderConstants', './RpcRegistration', 'jquery'], function(EventBus, Logger, ProcessingContext, uuid, Envelope, EnvelopeHelper, EnvelopeHeaderConstants, RpcRegistration, $) {
  var RpcBus, _ref;
  RpcBus = (function(_super) {
    __extends(RpcBus, _super);

    function RpcBus() {
      _ref = RpcBus.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    RpcBus.prototype.getResponseTo = function(config) {
      var deferred, env, inboundTopic, outboundTopic, request, requestId, timeout,
        _this = this;
      if (config == null) {
        config = {};
      }
      request = config.request, timeout = config.timeout, outboundTopic = config.outboundTopic, inboundTopic = config.inboundTopic;
      Logger.log.info("RpcBus.getResponseTo >> executing get response");
      deferred = $.Deferred();
      requestId = uuid.v4();
      env = this.buildRequestEnvelope(requestId, timeout, outboundTopic);
      this.processOutbound(request, env).then(function() {
        var rpcRegistration;
        rpcRegistration = new RpcRegistration({
          requestId: requestId,
          expectedTopic: inboundTopic,
          inboundChain: _this.inboundProcessors
        });
        return _this.envelopeBus.register(rpcRegistration).then(function() {
          _this.envelopeBus.send(env);
          return rpcRegistration.getResponse().then(function(data) {
            _this.envelopeBus.unregister(rpcRegistration);
            return deferred.resolve(data);
          });
        });
      });
      return deferred.promise();
    };

    RpcBus.prototype.buildRequestEnvelope = function(requestId, timeout, expectedTopic) {
      var env, envelopeHelper;
      env = new Envelope();
      envelopeHelper = new EnvelopeHelper(env);
      if (_.isString(expectedTopic)) {
        envelopeHelper.setMessageType(expectedTopic);
        envelopeHelper.setMessageTopic(expectedTopic);
      }
      envelopeHelper.setMessageId(requestId);
      envelopeHelper.setMessagePattern(EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC);
      envelopeHelper.setRpcTimeout(timeout);
      return env;
    };

    return RpcBus;

  })(EventBus);
  return RpcBus;
});
