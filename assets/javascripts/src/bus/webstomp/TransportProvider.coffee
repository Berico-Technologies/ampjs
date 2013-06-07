define [
  './Listener'
  'underscore'
  'jquery'
  '../../Logger'
],
(Listener, _, $, Logger)->
  class TransportProvider
    listeners:{}
    envCallbacks: []
    constructor: (config) ->
      config = config ? {}
      @topologyService = config.topologyService ? {}
      @channelProvider = config.channelProvider ? {}

    register: (registration)->
      deferred = $.Deferred()
      pendingListeners = []
      routing = @topologyService.getRoutingInfo(registration.registrationInfo)
      exchanges = _.pluck routing.routes, 'consumerExchange'

      for exchange in exchanges
        listenerDeferred = $.Deferred()
        pendingListeners.push listenerDeferred
        @_createListener(registration, exchange).then (listener)=>
          listenerDeferred.resolve()
          @listeners[registration] = listener
      $.when(pendingListeners).done ->
        deferred.resolve()
      return deferred
    _createListener:(registration, exchange) ->
      deferred = $.Deferred()
      @channelProvider.getConnection(exchange).then (connection)=>
        listener = @_getListener(registration, exchange)

        listener.onEnvelopeReceived({
          handleRecieve: (dispatcher)=>
            Logger.log.info  "TransportProvider._createListener >> handleRecieve called"
            @raise_onEnvelopeRecievedEvent(dispatcher)
          })

        listener.onClose({
          onClose: (registration)=> delete @listeners[registration]
          })

        deferred.resolve(listener)

        listener.start(connection)

    _getListener: (registration, exchange)->
      new Listener(registration, exchange)
    send: (envelope)->
      deferred = $.Deferred()
      pendingExchanges = []
      routing = @topologyService.getRoutingInfo(envelope.getHeaders())
      exchanges = _.pluck routing.routes, 'producerExchange'

      for exchange in exchanges
        exchangeDeferred = $.Deferred()
        pendingExchanges.push(exchangeDeferred)

        @channelProvider.getConnection(exchange).then (connection, existing)->
          newHeaders = {}
          headers = envelope.getHeaders
          for entry of headers
            newHeaders[entry] = headers[entry]

          Logger.log.info "TransportProvider.send >> declaring exchange #{exchange.name}"

          req = $.ajax
            url: 'http://localhost:8080/rabbit/declareExchange'
            type: "GET"
            dataType: 'jsonp'
            data: data: JSON.stringify
                exchangeName: exchange.name
                exchangeType: exchange.exchangeType
                exchangeIsDurable: exchange.isDurable
                exchangeIsAutoDelete: exchange.autoDelete
                exchangeArguments: exchange.arguments

          req.done (data, textStatus, jqXHR)->
              Logger.log.info "TransportProvider.send >> sending message to /exchange/#{exchange.name}/#{exchange.routingKey}"
              exchangeDeferred.resolve()
              connection.send("/exchange/#{exchange.name}/#{exchange.routingKey}",newHeaders,envelope.getPayload)
          req.fail (jqXHR, textStatus, errorThrown)->
              exchangeDeferred.reject()

      $.when(pendingExchanges).done ->
        deferred.resolve()

      return deferred

    unregister: (registration)->
      delete listeners[registration]
    onEnvelopeRecieved: (callback)->
      @envCallbacks.push(callback)
    raise_onEnvelopeRecievedEvent: (dispatcher)->
      for callback in @envCallbacks
        callback.handleRecieve(dispatcher)
    dispose: ->
      channelFactory.dispose
      topologyService.dispose
      for listener of listeners
        listener.dispose


  return TransportProvider
