define [
  './Listener'
  'underscore'
],
(Listener, _)->
  class TransportProvider
    listeners:{}
    constructor: (config) ->
      config = config ? {}
      topologyService = config.topologyService ? {}
      channelProvider = config.channelProvider ? {}
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
    send: ->
    unregister: ->
    onEnvelopeRecieved: ->
    dispose: ->
    _finalize: ->

  return TransportProvider
