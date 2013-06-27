define [
  './SimpleTopologyService'
  '../../bus/berico/EnvelopeHeaderConstants'
  '../../util/Logger'
],
(SimpleTopoologyService, EnvelopeHeaderConstants, Logger)->
  class DefaultApplicationExchangeProvider extends SimpleTopoologyService
      constructor: (@managementHostname, @managementPort, @managementServiceUrl, clientProfile, name, hostname, vhost, port)->
        super(clientProfile, name, hostname, vhost, port)
      getFallbackRoute: (topic)->
        headers = []
        headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = topic
        return @getRoutingInfo(headers)
      createRoute: (exchange)->
        deferred = $.Deferred()
        req = $.ajax
          url: "http://#{@managementHostname}:#{@managementPort}#{@managementServiceUrl}"
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