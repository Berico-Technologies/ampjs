define [
  '../../bus/berico/EnvelopeHeaderConstants'
  './ProcessingContext'
  '../../util/Logger'
],
(EnvelopeHeaderConstants, ProcessingContext, Logger) ->
  class EventRegistration
    filterPredicate: null
    registrationInfo: {}
    constructor: (@eventHandler, @inboundChain)->
      @registrationInfo[EnvelopeHeaderConstants.MESSAGE_TOPIC] = eventHandler.getEventType()

    handle:(envelope)->
      Logger.log.info "EventRegistration.handle >> received new envelope"
      ev = {}
      processorContext = new ProcessingContext(envelope, ev)
      if(@processInbound processorContext)
        @eventHandler.handle processorContext.getEvent(), processorContext.getEnvelope().getHeaders()


    processInbound:(processorContext)->
      Logger.log.info "EventRegistration.processInbound >> processing inbound queue"
      processed = true
      for processor in @inboundChain
        processor = false unless processor.processInbound processorContext
        break unless processor
      return processed
    handleFailed: (envelope, exception)->
      eventHandler.handleFailed(envelope,exception)
  return EventRegistration