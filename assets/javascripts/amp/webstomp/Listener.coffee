define [
  'underscore'
  '../bus/Envelope'
  '../bus/berico/EnvelopeHelper'
  './EnvelopeDispatcher'
  'jquery'
  '../util/Logger'
],
(_, Envelope, EnvelopeHelper, EnvelopeDispatcher, $, Logger)->
  class Listener
    envCallbacks: []
    closeCallbacks: []
    connectionErrorCallbacks: []

    constructor: (@registration, @exchange)->

    onEnvelopeReceived: (callback)->
      @envCallbacks.push(callback)

    onClose: (callback)->
      @closeCallbacks.push(callback)

    onConnectionError: (callback)->
      @connectionErrorCallbacks.push(callback)

    start: (@channel)->
      deferred = $.Deferred()
      Logger.log.info "Listener.start >> subscribing to /queue/#{@exchange.queueName}"
      channel.subscribe("/amq/queue/#{@exchange.queueName}", _.bind(@handleNextDelivery, @))
      deferred.resolve()
      deferred.promise()

    handleNextDelivery: (result)->
      Logger.log.info "Listener.handleNextDelivery >> received a message"
      envelopeHelper = @createEnvelopeFromDeliveryResult(result)
      if @shouldRaiseEvent @registration, envelopeHelper
        Logger.log.info "Listener.handleNextDelivery >> raising event from received message"
        @dispatchEnvelope envelopeHelper.getEnvelope()

    dispatchEnvelope: (envelope)->
      dispatcher = new EnvelopeDispatcher(@registration, envelope, @channel)
      @raise_onEnvelopeRecievedEvent dispatcher

    raise_onEnvelopeRecievedEvent: (dispatcher) ->
      callback.handleRecieve dispatcher for callback in @envCallbacks

    shouldRaiseEvent: (registration, envelopeHelper)->
      if envelopeHelper.getMessageTopic() == registration.eventHandler.getEventType()
        filter = registration.filterPredicate
        envelope = envelopeHelper.getEnvelope()
        if (_.isNull(filter) || !(_.isObject filter))
          return true
        else filter.filter envelope
      else
        return false

    createEnvelopeFromDeliveryResult: (result)->
      envelopeHelper = new EnvelopeHelper(new Envelope())
      envelopeHelper.setReciptTime(new Date().getMilliseconds)
      envelopeHelper.setPayload result.body

      for prop in _.keys(result.headers)
        envelopeHelper.setHeader(prop,result.headers[prop])

      return envelopeHelper
    dispose:->
      #unneeded here

  return Listener