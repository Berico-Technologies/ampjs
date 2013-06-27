define(['underscore', '../berico/InboundEnvelopeProcessorCallback', '../../util/Logger'], function(_, InboundEnvelopeProcessorCallback, Logger) {
  var EnvelopeBus;

  EnvelopeBus = (function() {
    function EnvelopeBus(transportProvider, inboundProcessors, outboundProcessors) {
      this.transportProvider = transportProvider;
      this.inboundProcessors = inboundProcessors != null ? inboundProcessors : [];
      this.outboundProcessors = outboundProcessors != null ? outboundProcessors : [];
      this.initialize();
    }

    EnvelopeBus.prototype.dispose = function() {
      var p, _i, _j, _len, _len1, _ref, _ref1, _results;

      _ref = this.inboundProcessors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        p.dispose();
      }
      _ref1 = this.outboundProcessors;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        p = _ref1[_j];
        _results.push(p.dispose());
      }
      return _results;
    };

    EnvelopeBus.prototype.initialize = function() {
      Logger.log.info("EnvelopeBus.initialize >> initialized");
      return this.transportProvider.onEnvelopeRecieved(new InboundEnvelopeProcessorCallback(this));
    };

    EnvelopeBus.prototype.processInbound = function(envelope) {
      var context, inboundProcessor, _i, _len, _ref, _results;

      Logger.log.info("EnvelopeBus.processInbound >> executing processors");
      context = {};
      _ref = this.inboundProcessors;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        inboundProcessor = _ref[_i];
        _results.push(inboundProcessor.processInbound(envelope, context));
      }
      return _results;
    };

    EnvelopeBus.prototype.processOutbound = function(envelope) {
      var context, outboundProcessor, _i, _len, _ref, _results;

      Logger.log.info("EnvelopeBus.processOutbound >> executing processors");
      context = {};
      _ref = this.outboundProcessors;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        outboundProcessor = _ref[_i];
        _results.push(outboundProcessor.processOutbound(envelope, context));
      }
      return _results;
    };

    EnvelopeBus.prototype.register = function(registration) {
      if (!_.isNull(registration)) {
        return this.transportProvider.register(registration);
      }
    };

    EnvelopeBus.prototype.send = function(envelope) {
      Logger.log.info("EnvelopeBus.send >> sending envelope");
      this.processOutbound(envelope);
      return this.transportProvider.send(envelope);
    };

    EnvelopeBus.prototype.setInboundProcessors = function(inboundProcessors) {
      this.inboundProcessors = inboundProcessors;
    };

    EnvelopeBus.prototype.setOutboundProcessors = function(outboundProcessors) {
      this.outboundProcessors = outboundProcessors;
    };

    EnvelopeBus.prototype.unregister = function(registration) {
      return this.transportProvider.unregister(registration);
    };

    return EnvelopeBus;

  })();
  return EnvelopeBus;
});
