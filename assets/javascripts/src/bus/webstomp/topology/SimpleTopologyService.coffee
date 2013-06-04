define [
  'uuid'
  '../../../Logger'
  './RoutingInfo'
  './RouteInfo'
  './Exchange'
  'underscore'
  '../../EnvelopeHeaderConstants'
],
(uuid, Logger, RoutingInfo, RouteInfo, Exchange, _,EnvelopeHeaderConstants)->
  class SimpleTopologyService
    constructor: (clientProfile, name, hostname, vhost, port) ->
      @clientProfile = if _.isString clientProfile then clientProfile else uuid.v1()
      @name = if _.isString name then name else "cmf.simple.exchange"
      @hostname = if _.isString hostname then hostname else "127.0.0.1"
      @virtualHost = if _.isString vhost then vhost else "/stomp"
      @port = if _.isNumber port then port else 15674
      @QUEUE_NUMBER = 0

    getRoutingInfo: (headers) ->
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

      new RoutingInfo([theOneRoute])

    buildIdentifiableQueueName: (topic)->
      "#{@clientProfile}##{@pad(++@QUEUE_NUMBER,3,0)}##{topic}"
    pad: (n,width,z)->
      z = z || '0';
      n = n + '';
      if n.length >= width then n else new Array(width - n.length + 1).join(z) + n;
    dispose: ->
      #currently empty



  return SimpleTopologyService
