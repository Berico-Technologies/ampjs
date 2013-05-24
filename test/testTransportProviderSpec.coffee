define [
  'src/bus/TransportProviderFactory'
  'src/bus/inmemory/TransportProvider'
  'src/bus/webstomp/TransportProvider'
  'underscore'
],
(TransportProviderFactory, InMemoryTransportProvider, WebStompTransportProvider, _) ->
  describe 'TransportProviderFactory', ->
    it 'needs to be able to be instantiated', ->
      tpf = new TransportProviderFactory()

    it 'needs to return in memory provider', ->

      config =
        transportProvider: TransportProviderFactory.TransportProviders.InMemory

      provider = TransportProviderFactory.getTransportProvider(config)
      assert provider instanceof InMemoryTransportProvider

    it 'needs to return in web stomp provider', ->

          config =
            transportProvider: TransportProviderFactory.TransportProviders.WebStomp

          provider = TransportProviderFactory.getTransportProvider(config)
          assert provider instanceof WebStompTransportProvider

