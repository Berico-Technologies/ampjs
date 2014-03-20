define [
  './SimpleTopologyService'
  '../../bus/berico/EnvelopeHeaderConstants'
  '../../util/Logger'
  'jsonp'
],
(SimpleTopologyService, EnvelopeHeaderConstants, Logger)->
  class DefaultApplicationExchangeProvider extends SimpleTopologyService
    constructor: (config={})->
      {@managementHostname, @managementPort, @managementServiceUrl, @connectionStrategy, clientProfile, exchangeName, exchangeHostname, exchangeVhost, exchangePort} = config

      #defaults for GTS
      unless _.isString @managementHostname then @managementHostname = 'localhost'
      unless _.isNumber @managementPort then @managementPort = 15677
      unless _.isString @managementServiceUrl then @managementServiceUrl = '/service/fallbackRouting/routeCreator'
      unless _.isFunction @connectionStrategy then @connectionStrategy = ->
        "https://#{@managementHostname}:#{@managementPort}#{@managementServiceUrl}"

      super({
        clientProfile: clientProfile
        name: exchangeName
        hostname: exchangeHostname
        vhost: exchangeVhost
        port: exchangePort
      })

    getFallbackRoute: (topic, create=true)->
      headers = []
      headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = topic
      return @getRoutingInfo(headers, create)

    createRoute: (exchange)->
      deferred = $.Deferred()
      req = $.jsonp(
        url: @connectionStrategy()
        callbackParameter: 'callback'
        data:
          data: JSON.stringify exchange
      ).then(
        (data, textStatus, jqXHR)->
          Logger.log.info "DefaultApplicationExchangeProvider.createRoute >> created route"
          deferred.resolve(data)
        ()->
          Logger.log.error "DefaultApplicationExchangeProvider.createRoute >> failed to create route"
          deferred.reject if arguments.length > 1 then Array.prototype.slice.call(arguments, 0) else arguments[0]
      )
      return deferred.promise()

  return DefaultApplicationExchangeProvider