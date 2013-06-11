define [
  '../../../bus/berico/EnvelopeHelper'
  '../../../util/Logger'
],
(EnvelopeHelper, Logger)->
  class JsonEventSerializer

    processInbound: (context)->
      Logger.log.info "JsonEventSerializer.processInbound >> deserializing payload"
      env = new EnvelopeHelper(context.getEnvelope())
      context.setEvent(JSON.parse(env.getPayload()))


    processOutbound: (context)->
      Logger.log.info "JsonEventSerializer.processOutbound >> serializing payload"
      context.getEnvelope().setPayload(JSON.stringify(context.getEvent()))

  return JsonEventSerializer