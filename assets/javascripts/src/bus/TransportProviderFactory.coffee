define [
  './webstomp/TransportProvider'
  './webstomp/ChannelProvider'
  './inmemory/TransportProvider'
  './inmemory/ChannelProvider'
  './topology/SimpleTopologyService'
  'underscore'
],
(WebStompTransportProvider, WebStompChannelProvider, InMemoryTransportProvider, InMemoryChannelProvider, SimpleTopologyService, _) ->
  class TransportFactory
    @TransportProviders:
      WebStomp: 'webstomp'
      InMemory: 'inmemory'
    @TopologyServices:
      Simple: 'simple'
    @ChannelFactories:
      WebStomp: 'webstomp'
      InMemory: 'inmemory'

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
          when TransportFactory.ChannelFactories.InMemory then channelProvider = new InMemoryChannelProvider()

      #throw back the correct instance. default the service and factory if they weren't provided
      switch config.transportProvider
        when TransportFactory.TransportProviders.WebStomp
          topologyService = new SimpleTopologyService() if _.isEmpty topologyService
          channelProvider = new WebStompChannelProvider() if _.isEmpty channelProvider
          config =
            topologyService: topologyService
            channelProvider: channelProvider
          new WebStompTransportProvider(config)

        when TransportFactory.TransportProviders.InMemory
          topologyService = new SimpleTopologyService() if _.isEmpty topologyService
          channelProvider = new InMemoryChannelProvider() if _.isEmpty channelProvider
          config =
            topologyService: topologyService
            channelProvider: channelProvider
          new InMemoryTransportProvider(config)
  return TransportFactory