define [
  './SimpleTopologyService'
  '../../bus/berico/EnvelopeHeaderConstants'
  '../../util/Logger'
],
(SimpleTopoologyService, EnvelopeHeaderConstants, Logger)->
  class DefaultApplicationExchangeProvider extends SimpleTopoologyService
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
      getFallbackRoute: (topic)->
        headers = []
        headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = topic
        return @getRoutingInfo(headers)
      createRoute: (exchange)->
        deferred = $.Deferred()
        req = $.ajax
          url: @connectionStrategy()
          dataType: 'jsonp'
          data: data: JSON.stringify exchange
        req.done (data, textStatus, jqXHR)->
            Logger.log.info "DefaultApplicationExchangeProvider.createRoute >> created route"
            deferred.resolve(data)
        req.fail (jqXHR, textStatus, errorThrown)->
            Logger.log.error "DefaultApplicationExchangeProvider.createRoute >> failed to create route"
            deferred.reject()
        return deferred.promise()
  return DefaultApplicationExchangeProvider