define [
  '../../util/Logger'
  'jquery'
  'jsonp'
],
(Logger)->
    class RoutingInfoRetriever
      constructor: (config={})->
        {@hostname, @port, @serviceUrlExpression, @connectionStrategy} = config
        unless _.isString @hostname then @hostname = '127.0.0.1'
        unless _.isNumber @port then @port = 15677
        unless _.isString @serviceUrlExpression then @serviceUrlExpression = "/service/topology/get-routing-info"
        unless _.isFunction @connectionStrategy then @connectionStrategy = (topic)->
          "https://#{@hostname}:#{@port}#{@serviceUrlExpression}/#{topic}?c=true"

      retrieveRoutingInfo: (topic)->
        Logger.log.info "RoutingInfoRetriever.retrieveRoutingInfo >> Getting routing info for topic: #{topic}"
        deferred = $.Deferred()
        req = $.jsonp(
          url: @connectionStrategy(topic).replace(/#[^\?]*/, '') # remove the stuff beteween the # and the ? which confuses jsonp
          callbackParameter: 'callback'
        ).then(
          (data, textStatus, jqXHR)->
            Logger.log.info "RoutingInfoRetriever.retrieveRoutingInfo >> retrieved topic info"
            deferred.resolve(data)
          ()->
            Logger.log.error "RoutingInfoRetriever.retrieveRoutingInfo >> failed to retrieve topic info"
            deferred.reject if arguments.length > 1 then Array.prototype.slice.call(arguments, 0) else arguments[0]
        )
        return deferred.promise()

    return RoutingInfoRetriever