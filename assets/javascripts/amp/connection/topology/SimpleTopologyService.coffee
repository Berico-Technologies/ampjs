define [
  'uuid'
  '../../util/Logger'
  './RoutingInfo'
  './RouteInfo'
  './Exchange'
  'underscore'
  '../../bus/berico/EnvelopeHeaderConstants'
  'jquery'
],
(uuid, Logger, RoutingInfo, RouteInfo, Exchange, _,EnvelopeHeaderConstants, $)->
  class SimpleTopologyService
    constructor: (config={}) ->
      {@clientProfile, @name, @hostname, @virtualHost, @port, @queue_number} = config
      unless _.isString @clientProfile then @clientProfile = uuid.v4()
      unless _.isString @name then @name = 'cmf.simple.exchange'
      unless _.isString @hostname then @hostname = '127.0.0.1'
      unless _.isString @virtualHost then @virtualHost = '/stomp'
      unless _.isNumber @port then @port = 15678
      unless _.isNumber @queue_number then @queue_number = 0

    getRoutingInfo: (headers, create) ->
      deferred = $.Deferred()
      topic = headers[EnvelopeHeaderConstants.MESSAGE_TOPIC]
      theOneExchange = new Exchange(
        @name, #exchange name
        @hostname, #host name
        @virtualHost, #virtual host
        @port, #port
        topic, #routing key
        @buildIdentifiableQueueName(topic), #topic
        "direct", #exchange type
        false, #is durable
        true, #is auto-delete
        null) #arguments

      theOneRoute = new RouteInfo(theOneExchange, theOneExchange)
      if create
        @createRoute(theOneExchange).then (data)->
          deferred.resolve(new RoutingInfo([theOneRoute]))
      else
        setTimeout (->deferred.resolve(new RoutingInfo([theOneRoute]))), 1

      return deferred.promise()

    createRoute: (exchange)->
      deferred = $.Deferred()
      deferred.resolve(null)
      return deferred.promise()

    buildIdentifiableQueueName: (topic)->
      #should only be called when subscribing
      if(topic.indexOf("#") == -1)
        "#{@clientProfile}##{@pad(++@queue_number,3,0)}##{topic}"

      #should be used when publishing
      else
        topic
    pad: (n,width,z)->
      z = z || '0';
      n = n + '';
      if n.length >= width then n else new Array(width - n.length + 1).join(z) + n;
    dispose: ->
      #currently empty



  return SimpleTopologyService
