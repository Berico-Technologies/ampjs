define [
  'underscore'
  '../../Logger'
],
(_, Logger) ->
  class TransportProvider
    constructor: (config) ->
      config = config ? {}
      topologyService = config.topologyService ? {}
      channelProvider = config.channelProvider ? {}
      Logger.log.info "TransportProvider TopologyService not initialized" if _.isEmpty topologyService
    register: ->
    _createListener: ->
    _getListener: ->
    send: ->
    unregister: ->
    onEnvelopeRecieved: ->
    dispose: ->
    _finalize: ->


  return TransportProvider
