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
    serviceUrl: 'http://localhost:8080/rabbit/createBinding'

    constructor: (@registration, @exchange)->

    onEnvelopeReceived: (callback)->
      @envCallbacks.push(callback)

    onClose: (callback)->
      @closeCallbacks.push(callback)

    onConnectionError: (callback)->
      @connectionErrorCallbacks.push(callback)

    start: (@channel)->
      Logger.log.info "Listener.start >> subscribing to /queue/#{@exchange.queueName}"
      channel.subscribe("/queue/#{@exchange.queueName}", _.bind(@handleNextDelivery, @))
      @createBinding()

    createBinding: ()->
      Logger.log.info "Listener.createBinding >> binding queue to exchange"
      deferred = $.Deferred()
      req = $.ajax
        url: @serviceUrl
        dataType: 'jsonp'
        data: data: JSON.stringify
          exchangeName: @exchange.name
          exchangeType: @exchange.exchangeType
          exchangeIsDurable: @exchange.isDurable
          exchangeIsAutoDelete: @exchange.autoDelete
          exchangeArguments: @exchange.arguments

          queueName: @exchange.queueName
          queueIsDurable: @exchange.isDurable
          queueIsExclusive: false
          queueIsAutoDelete: @exchange.autoDelete
          queueArguments: @exchange.arguments

          routingKey: @exchange.routingKey
      req.done (data, textStatus, jqXHR)->
          deferred.resolve()
      req.fail (jqXHR, textStatus, errorThrown)->
          deferred.reject()
      return deferred

    handleNextDelivery: (result)->
      Logger.log.info "Listener.handleNextDelivery >> received a message"
      envelopeHelper = @createEnvelopeFromDeliveryResult(result)
      if @shouldRaiseEvent @registration.filterPredicate, envelopeHelper.getEnvelope()
        Logger.log.info "Listener.handleNextDelivery >> raising event from received message"
        @dispatchEnvelope envelopeHelper.getEnvelope()

    dispatchEnvelope: (envelope)->
      dispatcher = new EnvelopeDispatcher(@registration, envelope, @channel)
      @raise_onEnvelopeRecievedEvent dispatcher

    raise_onEnvelopeRecievedEvent: (dispatcher) ->
      callback.handleRecieve dispatcher for callback in @envCallbacks

    shouldRaiseEvent: (filter, envelope)->
      if (_.isNull(filter) || !(_.isObject filter))
        return true
      else filter.filter envelope

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