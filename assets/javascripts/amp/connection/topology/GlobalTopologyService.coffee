define [
  '../../util/Logger'
  'LRUCache'
  'underscore'
  '../../bus/berico/EnvelopeHeaderConstants'
  'jquery'
  ],
(Logger, LRUCache, _, EnvelopeHeaderConstants, $)->
  class GlobalTopologyService
    @CACHE_EXPIRY_TIME_IN_MS: 1000000
    routingInfoCache: {}
    fallbackProvider: null

    constructor: (config = {})->
      {@routingInfoRetriever, cacheExpiryTime, @fallbackProvider, @exchangeOverrides} = config
      unless _.isObject @exchangeOverrides then @exchangeOverrides =
        port: 15678
        vHost: '/stomp'

      @routingInfoCache = new LRUCache(
        maxAge: if _.isNumber cacheExpiryTime then cacheExpiryTime else GlobalTopologyService.CACHE_EXPIRY_TIME_IN_MS
      )

    getRoutingInfo: (routingHints, create=true)->
      deferred = $.Deferred()
      topic = routingHints[EnvelopeHeaderConstants.MESSAGE_TOPIC]
      Logger.log.info "GlobalTopologyService.getRoutingInfo>> Getting routing info for topic: #{topic}"
      routingInfo = @routingInfoCache.get(topic)
      if _.isUndefined routingInfo
        Logger.log.info "GlobalTopologyService.getRoutingInfo>> route not in cache, attempting external lookup"
        @routingInfoRetriever.retrieveRoutingInfo(topic).then(
          (data)=>
            if _.has(data, 'routes') && _.size(data.routes) > 0
              Logger.log.info "GlobalTopologyService.getRoutingInfo>> Successfully retrieved #{_.size data.routes} GTS routes"
              @_fixExhangeInformation(data)
              @routingInfoCache.set topic, data
              deferred.resolve(data)
            else
                Logger.log.info "GlobalTopologyService.getRoutingInfo>> no route in GTS: using fallback route"
                @fallbackProvider.getFallbackRoute(topic, create).then(
                  (data)->
                    deferred.resolve(data)
                  () ->
                    deferred.reject if arguments.length > 1 then Array.prototype.slice.call(arguments, 0) else arguments[0]
                )
          ()->
            deferred.reject if arguments.length > 1 then Array.prototype.slice.call(arguments, 0) else arguments[0]
        )
      else
        Logger.log.info "GlobalTopologyService.getRoutingInfo>> cache hit, returning route without lookup"
        deferred.resolve(routingInfo)
      return deferred.promise()

    _fixExhangeInformation: (routingInfo)->
      for route in routingInfo.routes
        for override, value of @exchangeOverrides
          route.consumerExchange[override] = value
          route.producerExchange[override] = value


  return GlobalTopologyService