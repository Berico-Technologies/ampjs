define [
  'underscore'
  '../berico/InboundEnvelopeProcessorCallback'
  '../../util/Logger'
],
(_, InboundEnvelopeProcessorCallback, Logger)->

  class EnvelopeBus
    constructor: (@transportProvider, @inboundProcessors = [], @outboundProcessors = [])->
      @initialize()

    dispose: =>
      p.dispose() for p in @inboundProcessors
      p.dispose() for p in @outboundProcessors

    initialize: =>
      Logger.log.info "EnvelopeBus.initialize >> initialized"
      @transportProvider.onEnvelopeRecieved new InboundEnvelopeProcessorCallback(this)

    processInbound: (envelope) =>
      Logger.log.info "EnvelopeBus.processInbound >> executing processors"
      context = {}
      inboundProcessor.processInbound(envelope, context) for inboundProcessor in @inboundProcessors

    processOutbound: (envelope) =>
      Logger.log.info "EnvelopeBus.processOutbound >> executing processors"
      context = {}

      deferred = $.Deferred()
      looper = $.Deferred().resolve()
      for outboundProcessor in @outboundProcessors
        do (outboundProcessor) =>
          looper = looper.then(
            () ->
              return outboundProcessor.processOutbound(envelope, context)
            () ->
              deferred.reject {error: 'EnvelopeBus.processOutbound >> error in outbound processors', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
          )

      looper.then(
        () ->
          Logger.log.info "EnvelopeBus.processOutbound >> all outbound processors executed"
          deferred.resolve()
        () ->
          deferred.reject {error: 'EnvelopeBus.processOutbound >> error in outbound processors', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
      )
      return deferred.promise()

    register: (registration) =>
      @transportProvider.register registration unless _.isNull registration

    send: (envelope) =>
      deferred = $.Deferred()
      Logger.log.info "EnvelopeBus.send >> sending envelope"
      @processOutbound(envelope).then(
        () =>
          @transportProvider.send(envelope).then(
            () ->
              deferred.resolve()
            () ->
              deferred.reject {error: 'EnvelopeBus.send >> error in TransportProvider.send', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
          )

        () ->
          deferred.reject {error: 'EnvelopeBus.send >> error in processing envelope', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
      )

    setInboundProcessors: (@inboundProcessors)->

    setOutboundProcessors: (@outboundProcessors)->

    unregister: (registration) =>
      @transportProvider.unregister registration

  return EnvelopeBus