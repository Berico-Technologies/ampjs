define [
  './ProcessingContext'
  '../../bus/Envelope'
  './EventRegistration'
  '../../util/Logger'
  'jquery'
  '../../bus/berico/EnvelopeHelper'
  '../../bus/berico/EnvelopeHeaderConstants'
  'underscore'
],
(ProcessingContext, Envelope, EventRegistration, Logger, $, EnvelopeHelper, EnvelopeHeaderConstants, _)->
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
        looper = looper.then(
          () ->
            return outboundProcessor.processOutbound(context)
          () ->
            deferred.reject if arguments.length > 1 then Array.prototype.slice.call(arguments, 0) else arguments[0]
        )
      looper.then(
        () ->
          Logger.log.info "EventBus.processOutbound >> all outbound processors executed"
          deferred.resolve()
        () ->
          deferred.reject if arguments.length > 1 then Array.prototype.slice.call(arguments, 0) else arguments[0]
      )
      return deferred.promise()

    publish: (event, expectedTopic)->
      envelope = new Envelope()
      helper = new EnvelopeHelper(envelope)

      helper.setMessagePattern EnvelopeHeaderConstants.MESSAGE_PATTERN_PUBSUB

      if _.isString expectedTopic
        helper.setMessageType expectedTopic
        helper.setMessageTopic expectedTopic

      @processOutbound(event, envelope).then =>
        @envelopeBus.send(envelope)

    subscribe: (eventHandler)->
      registration = new EventRegistration(eventHandler, @inboundProcessors)
      @envelopeBus.register(registration)

  return EventBus