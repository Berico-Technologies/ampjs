define [
  './ProcessingContext'
  '../../bus/Envelope'
  './EventRegistration'
  '../../util/Logger'
  'jquery'
],
(ProcessingContext, Envelope, EventRegistration, Logger, $)->
  class EventBus
    constructor: (@envelopeBus, @inboundProcessors=[], @outboundProcessors=[])->
    dispose: ->
      @envelopeBus.dispose()
    finalize: ->
      @dispose()
    processOutbound: (event, envelope)->
      Logger.log.info "EventBus.processOutbound >> executing processors"
      context = new ProcessingContext(envelope, event)
      deferred = $.Deferred()
      looper = $.Deferred().resolve()
      for outboundProcessor in @outboundProcessors
        looper = looper.then ->
          return outboundProcessor.processOutbound(context)
      looper.then ->
        Logger.log.info "EventBus.processOutbound >> all outbound processors executed"
        deferred.resolve()
      return deferred.promise()
    publish: (event)->
      envelope = new Envelope()
      @processOutbound(event, envelope).then ->
        @envelopeBus.send(envelope)
    subscribe: (eventHandler)->
      registration = new EventRegistration(eventHandler, @inboundProcessors)
      @envelopeBus.register(registration)

  return EventBus