define(['../../../bus/berico/EnvelopeHelper', '../../../util/Logger'], function(EnvelopeHelper, Logger) {
  var JsonEventSerializer;
  JsonEventSerializer = (function() {
    function JsonEventSerializer() {}

    JsonEventSerializer.prototype.processInbound = function(context) {
      var env;
      Logger.log.info("JsonEventSerializer.processInbound >> deserializing payload");
      env = new EnvelopeHelper(context.getEnvelope());
      return context.setEvent(JSON.parse(env.getPayload()));
    };

    JsonEventSerializer.prototype.processOutbound = function(context) {
      Logger.log.info("JsonEventSerializer.processOutbound >> serializing payload");
      return context.getEnvelope().setPayload(JSON.stringify(context.getEvent()));
    };

    return JsonEventSerializer;

  })();
  return JsonEventSerializer;
});
