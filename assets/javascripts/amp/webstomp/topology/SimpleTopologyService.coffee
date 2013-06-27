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
    constructor: (@clientProfile=uuid.v4(), @name='cmf.simple.exchange', @hostname='127.0.0.1', @virtualHost='/stomp', @port=15674, @QUEUE_NUMBER=0) ->


    getRoutingInfo: (headers) ->
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
      @createRoute(theOneExchange).then (data)->
        deferred.resolve(new RoutingInfo([theOneRoute]))

      return deferred.promise()

    createRoute: (exchange)->
      deferred = $.Deferred()
      deferred.resolve(null)
      return deferred.promise()

    buildIdentifiableQueueName: (topic)->
      "#{@clientProfile}##{@pad(++@QUEUE_NUMBER,3,0)}##{topic}"
    pad: (n,width,z)->
      z = z || '0';
      n = n + '';
      if n.length >= width then n else new Array(width - n.length + 1).join(z) + n;
    dispose: ->
      #currently empty



  return SimpleTopologyService
