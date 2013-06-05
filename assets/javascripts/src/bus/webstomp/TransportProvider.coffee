define [
  './Listener'
  'underscore'
],
(Listener, _)->
  class TransportProvider
    listeners:{}
    envCallbacks: []
    constructor: (config) ->
      config = config ? {}
      @topologyService = config.topologyService ? {}
      @channelProvider = config.channelProvider ? {}


    register: (registration)->
      routing = @topologyService.getRoutingInfo(registration.registrationInfo)
      exchanges = []
      exchanges.push exchange for exchange in routing.routes

      for exchange in exchanges
        listener = @_createListener(registration, exchange)
        @listeners[registration] = listener
    _createListener:(registration, exchange) ->
      channel = channelProvider.getChannel(exchange)
      listener = @_getListener(registration, exchange)

      listener.onEnvelopeRecieved({
        handleRecieve: (dispatcher)-> raise_onEnvelopeRecievedEvent(dispatcher)
        })

      listener.onClose({
        onClose: _.bind(((registration)-> delete @listeners[registration]),@)
        })

      listener.start(channel)

      return listener
    _getListener: (registration, exchange)->
      new Listener(registration, exchange)
    send: (envelope)->
      routing = @topologyService.getRoutingInfo(envelope.getHeaders())
      exchanges = _.pluck routing.routes, 'producerExchange'

      for exchange in exchanges
        @channelProvider.getConnection(exchange,(connection, existing)->
          newHeaders = {}
          headers = envelope.getHeaders
          for entry of headers
            newHeaders[entry] = headers[entry]
          connection.send("/exchange/#{exchange.name}/#{exchange.routingKey}",newHeaders,envelope.getPayload)
        )

    unregister: (registration)->
      delete listeners[registration]
    onEnvelopeRecieved: (callback)->
      envCallbacks.push(callback)
    raise_onEnvelopeRecievedEvent: (dispatcher)->
      for callback in envCallbacks
        callback.handleRecieve(dispatcher)
    dispose: ->
      channelFactory.dispose
      topologyService.dispose
      for listener of listeners
        listener.dispose


  return TransportProvider
