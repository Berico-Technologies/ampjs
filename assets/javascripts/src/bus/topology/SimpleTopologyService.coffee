define [
  'uuid'
],
(uuid)->
  class SimpleTopologyService
    constructor: (config) ->
      config = config ? {}
      topologyInfo = config.topology ? {}
      @routePrototype =
        clientProfile: topologyInfo.clientProfile ? uuid.v1()
        exchange: topologyInfo.exchange ? "cmf.simple.exchange"
        host: topologyInfo.host ? "localhost"
        port: topologyInfo.port ? 5672
        vhost: topologyInfo.vhost ? "/"
    getRoutingInfo: (context) =>
      logger.debug "SimpleTopologyService.getRoutingInfo >> getting routing info"
      route = _.clone @routePrototype
      route.routingKey = context[HeaderConstants.MESSAGE_TOPIC.key] ? context.topic
      route.queue = "#{@routePrototype.clientProfile}##{route.routingKey}"
      route.exchangeType = "direct"
      route.isDurable = true
      route.isAutoDelete = true
      routeInfo = { consumerRoute: route, producerRoute: route }
      return [ routeInfo ]
  return SimpleTopologyService
