define [
  '../../bus/berico/EnvelopeHelper'
  'jquery'
  './ProcessingContext'
  './EventRegistration'
  '../../util/Logger'
  '../../bus/berico/EnvelopeHeaderConstants'
],
(EnvelopeHelper, $, ProcessingContext, EventRegistration, Logger, EnvelopeHeaderConstants)->
  class RpcRegistration extends EventRegistration
    constructor: (config={})->
      {requestId, expectedTopic, @inboundChain} = config

      @responseFilter =
        filter: (envelope)->
          return new EnvelopeHelper(envelope).getCorrelationId() == requestId

      @registrationInfo = {}

      @registrationInfo[EnvelopeHeaderConstants.MESSAGE_TOPIC] = @buildRpcTopic(expectedTopic, requestId)


      @requestDeferred = $.Deferred()

    buildRpcTopic: (expectedTopic, requestId)->
      "#{expectedTopic}##{requestId}"

    getResponse: ()->
      @requestDeferred.promise()

    handle: (envelope)->
      Logger.log.info "RpcRegistration.handle >> received new envelope"
      processorContext = new ProcessingContext(envelope, envelope)
      if(@processInbound processorContext)
        @requestDeferred.resolve(processorContext.getEvent())


  return RpcRegistration