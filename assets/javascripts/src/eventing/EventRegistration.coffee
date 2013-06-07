define [
  '../bus/EnvelopeHeaderConstants'
  './ProcessingContext'
],
(EnvelopeHeaderConstants, ProcessingContext) ->
  class EventRegistration
    filterPredicate: null
    registrationInfo: {}
    constructor: (@eventHandler, @inboundChain)->
      @registrationInfo[EnvelopeHeaderConstants.MESSAGE_TOPIC] = eventHandler.getEventType()

    handle:(envelope)->
      ev = {}
      processorContext = new ProcessingContext(envelope, ev)
      if(@processInbound processorContext)
        @eventHandler.handle processorContext.getEvent(), processorContext.getEnvelope().getHeaders()


    processInbound:(processorContext)->
      processed = true
      for processor in @inboundChain
        processor = false unless processor.processInbound processorContext
      return processed
    handleFailed: (envelope, exception)->
      eventHandler.handleFailed(envelope,exception)
  return EventRegistration