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

      @eventHandler =
        getEventType: -> expectedTopic


      @responseFilter =
        filter: (envelope)->
          return new EnvelopeHelper(envelope).getCorrelationId() == requestId

      @registrationInfo = {}

      @registrationInfo[EnvelopeHeaderConstants.MESSAGE_TOPIC] = @buildRpcTopic(expectedTopic, requestId)

      @requestDeferred = $.Deferred()

    buildRpcTopic: (expectedTopic, requestId)->
      topic = "#{expectedTopic}##{requestId}"
      Logger.log.info "RpcRegistration.buildRpcTopic >> rpc topic is #{topic}"
      return topic

    getResponse: ()->
      @requestDeferred.promise()

    handle: (envelope)->
      Logger.log.info "RpcRegistration.handle >> received new envelope"
      processorContext = new ProcessingContext(envelope, envelope)
      if(@processInbound processorContext)
        @requestDeferred.resolve(processorContext.getEvent())
      else
        @requestDeferred.reject {error: 'RpcRegistration.handle >> error in processing inbound envelope'}


  return RpcRegistration