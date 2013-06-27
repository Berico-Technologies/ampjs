define [
  './ProcessingContext'
  '../../bus/Envelope'
  './EventRegistration'
  '../../util/Logger'
],
(ProcessingContext, Envelope, EventRegistration, Logger)->
  class EventBus
    constructor: (@envelopeBus, @inboundProcessors=[], @outboundProcessors=[])->
    dispose: ->
      @envelopeBus.dispose()
    finalize: ->
      @dispose()
    processOutbound: (event, envelope)->
      Logger.log.info "EventBus.processOutbound >> executing processors"
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