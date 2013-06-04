define [
  'underscore'
  '../Envelope'
  '../EnvelopeHelper'
  '../EnvelopeDispatcher'
],
(_, Envelope, EnvelopeHelper, EnvelopeDispatcher)->
  class Listener
    envCallbacks: []
    closeCallbacks: []
    connectionErrorCallbacks: []

    constructor: (@registration, @exchange)->

    onEnvelopeReceived: (callback)->
      envCallbacks.push(callback)

    onClose: (callback)->
      closeCallbacks.push(callback)

    onConnectionError: (callback)->
      connectionErrorCallbacks.push(callback)

    start: (@channel)->
      channel.subscribe(@exchange.routingKey, _.bind(@handleNextDelivery, @))

    handleNextDelivery: (result)->
      envelopeHelper = @createEnvelopeFromDeliveryResult(result)
      if @shouldRaiseEvent registration.filterPredicate, envelopeHelper.getEnvelope
        @dispatchEnvelope envelopeHelper.getEnvelope

    dispatchEnvelope: (envelope)->
      dispatcher = new EnvelopeDispatcher(@registration, envelope, @channel)
      raise_onEnvelopeRecievedEvent dispatcher

    raise_onEnvelopeRecievedEvent: (dispatcher) ->
      callback.handleRecieve dispatcher for callback in envCallbacks

    shouldRaiseEvent: (filter, envelope)->
      if (_.isNull filter || !(_.isObject filter))
        return true
      else filter.filter envelope

    createEnvelopeFromDeliveryResult: (result)->
      envelopeHelper = new EnvelopeHelper(new Envelope())
      envelopeHelper.setReceiptTime(new Date().getMilliseconds)
      envelopeHelper.setPayload result.body

      for prop in _.keys(result.headers)
        envelopeHelper.setHeader(prop,result.headers[prop])

      return envelopeHelper
    dispose:->
      #unneeded here

  return Listener