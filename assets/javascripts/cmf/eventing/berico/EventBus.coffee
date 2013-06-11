define [
  './ProcessingContext'
  '../../bus/Envelope'
  './EventRegistration'
],
(ProcessingContext, Envelope, EventRegistration)->
  class EventBus
    constructor: (@envelopeBus, inboundProcessors, outboundProcessors)->
      @inboundProcessors = if _.isArray inboundProcessors then inboundProcessors else @inboundProcessors
      @outboundProcessors = if _.isArray outboundProcessors then outboundProcessors else @outboundProcessors
    dispose: ->
      @envelopeBus.dispose()
    finalize: ->
      @dispose()
    processOutbound: (event, envelope)->
      context = new ProcessingContext(envelope, event)
      outboundProcessor.processOutbound(context) for outboundProcessor in @outboundProcessors
    publish: (event)->
      envelope = new Envelope()
      @processOutbound(event, envelope)
      @envelopeBus.send(envelope)
    subscribe: (eventHandler)->
      registration = new EventRegistration(eventHandler, @inboundProcessors)
      @envelopeBus.register(registration)

  return EventBus