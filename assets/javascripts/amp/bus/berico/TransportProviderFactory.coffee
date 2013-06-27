define [
  '../../webstomp/TransportProvider'
  '../../webstomp/ChannelProvider'
  '../../webstomp/topology/SimpleTopologyService'
  'underscore'
  '../../util/Logger'
],
(WebStompTransportProvider, WebStompChannelProvider, SimpleTopologyService, _, Logger) ->
  class TransportFactory
    @TransportProviders:
      WebStomp: 'webstomp'
    @TopologyServices:
      Simple: 'simple'
    @ChannelFactories:
      WebStomp: 'webstomp'

    @getTransportProvider: (config) ->
      Logger.log.info "TransportFactory.getTransportProvider >> getting transport provider"
      #if you'd like just send the provider and accept defaults that's cool with me
      if (!_.isObject(config) && _.isString(config))
        config =
          transportProvider: config

      #you can either pass in an instance of these or use one of the 'builtin' types
      if !_.isObject(config.topologyService) && _.isString(config.topologyService)
        switch config.topologyService
          when TransportFactory.TopologyServices.Simple then topologyService = new SimpleTopologyService()

      else if _.isObject(config.topologyService)
        topologyService = config.topologyService

      if !_.isObject(config.channelProvider) && _.isString(config.channelProvider)
        switch config.channelProvider
          when TransportFactory.ChannelFactories.WebStomp then channelProvider = new WebStompChannelProvider()

      else if _.isObject(config.channelProvider)
        channelProvider = config.channelProvider


      #throw back the correct instance. default the service and factory if they weren't provided
      switch config.transportProvider
        when TransportFactory.TransportProviders.WebStomp
          Logger.log.info "TransportFactory.getTransportProvider >> using default topology service" unless _.isObject topologyService
          topologyService = new SimpleTopologyService() unless _.isObject topologyService

          Logger.log.info "TransportFactory.getTransportProvider >> using default channel provider" unless _.isObject channelProvider
          channelProvider = new WebStompChannelProvider() unless _.isObject channelProvider

          config =
            topologyService: topologyService
            channelProvider: channelProvider
          new WebStompTransportProvider(config)


  return TransportFactory