define [], ->
  class TransportProvider
    constructor: (config) ->
      config = config ? {}
      topologyService = config.topologyService ? {}
      channelProvider = config.channelProvider ? {}
    register: ->
    _createListener: ->
    _getListener: ->
    send: ->
    unregister: ->
    onEnvelopeRecieved: ->
    dispose: ->
    _finalize: ->

  return TransportProvider
