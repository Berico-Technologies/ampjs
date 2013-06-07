define [
  'underscore'
  './InboundEnvelopeRecievedCallback'
  '../Logger'
],
(_, InboundEnvelopeRecievedCallback, Logger)->
  class EnvelopeBus
    inboundProcessors: []
    outboundProcessors: []

    constructor: (@transportProvider, inboundProcessors, outboundProcessors)->
      @inboundProcessors = if _.isArray inboundProcessors then inboundProcessors else @inboundProcessors
      @outboundProcessors = if _.isArray outboundProcessors then outboundProcessors else @outboundProcessors
      @initialize()

    dispose: ->
      p.dispose for p in @inboundProcessors
      p.dispose for p in @outboundProcessors

    initialize: ->
      Logger.log.info "EnvelopeBus.initialize >> initialized"
      @transportProvider.onEnvelopeRecieved new InboundEnvelopeRecievedCallback(this)

    processInbound: (envelope)->
      context = {}
      inboundProcessor.processInbound(envelope, context) for inboundProcessor in @inboundProcessors

    processOutbound: (envelope)->
      context = {}
      outboundProcessor.processOutbound(envelope, context) for outboundProcessor in @outboundProcessors

    register: (registration)->
      @transportProvider.register registration unless _.isNull registration

    send: (envelope)->
      Logger.log.info "EnvelopeBus.send >> sending envelope"
      @processOutbound(envelope)
      @transportProvider.send(envelope)

    setInboundProcessors: (@inboundProcessors)->

    setOutboundProcessors: (@outboundProcessors)->

    unregister: (registration)->
      @transportProvider.unregister registration

  return EnvelopeBus