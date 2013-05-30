define [
  '../bus/EnvelopeHeaderConstants'
],
(EnvelopeHeaderConstants) ->
  class EventRegistration
    filterPredicate: null
    constructor: (@eventHandler, @processorCallback)->
      @registrationInfo[EnvelopeHeaderConstants.MESSAGE_TOPIC] = eventHandler.getEventType

    handle:(envelope)->
      event = @processorCallback.ProcessInbound(envelope)
      @eventHandler.handle(event, envelope.getHeaders)
    handleFailed: (envelope, exception)->
      eventHandler.handleFailed(envelope,exception)
  return EventRegistration