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
        do (outboundProcessor) =>
          looper = looper.then(
            () =>
              return outboundProcessor.processOutbound(context)
            () =>
              deferred.reject {error: 'EventBus.processOutbound >> error in outbound processors', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
          )

      looper.then(
        () =>
          Logger.log.info "EventBus.processOutbound >> all outbound processors executed"
          deferred.resolve()
        () =>
          deferred.reject {error: 'EventBus.processOutbound >> error in outbound processors', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
      )
      return deferred.promise()

    publish: (event, expectedTopic)->
      envelope = new Envelope()
      helper = new EnvelopeHelper(envelope)

      helper.setMessagePattern EnvelopeHeaderConstants.MESSAGE_PATTERN_PUBSUB

      if _.isString expectedTopic
        helper.setMessageType expectedTopic
        helper.setMessageTopic expectedTopic

      deferred = $.Deferred()
      @processOutbound(event, envelope).then(
        () =>
          @envelopeBus.send(envelope).then(
            () =>
              deferred.resolve()
	          () =>
	            deferred.reject {error: 'EventBus.publish >> error publishing message', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
          )
        () =>
          deferred.reject {error: 'EventBus.publish >> error in outbound processors', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
      )

      return deferred.promise()

    subscribe: (eventHandler)->
      registration = new EventRegistration(eventHandler, @inboundProcessors)
      @envelopeBus.register(registration)

  return EventBus