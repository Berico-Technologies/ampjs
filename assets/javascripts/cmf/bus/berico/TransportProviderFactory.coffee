define [
  '../../webstomp/TransportProvider'
  '../../webstomp/ChannelProvider'
  '../../webstomp/topology/SimpleTopologyService'
  'underscore'
],
(WebStompTransportProvider, WebStompChannelProvider, SimpleTopologyService, _) ->
  class TransportFactory
    @TransportProviders:
      WebStomp: 'webstomp'
    @TopologyServices:
      Simple: 'simple'
    @ChannelFactories:
      WebStomp: 'webstomp'

    @getTransportProvider: (config) ->
      #if you'd like just send the provider and accept defaults that's cool with me
      if (!_.isObject(config) && _.isString(config))
        config =
          transportProvider: config

      #you can either pass in an instance of these or use one of the 'builtin' types
      if !_.isObject config.topologyService
        switch config.topologyService
          when TransportFactory.TopologyServices.Simple then topologyService = new SimpleTopologyService()

      if !_.isObject config.channelProvider
        switch config.channelProvider
          when TransportFactory.ChannelFactories.WebStomp then channelProvider = new WebStompChannelProvider()


      #throw back the correct instance. default the service and factory if they weren't provided
      switch config.transportProvider
        when TransportFactory.TransportProviders.WebStomp
          topologyService = new SimpleTopologyService() unless _.isObject topologyService
          channelProvider = new WebStompChannelProvider() unless _.isObject channelProvider
          config =
            topologyService: topologyService
            channelProvider: channelProvider
          new WebStompTransportProvider(config)


  return TransportFactory