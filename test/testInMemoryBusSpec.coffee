define [
  'src/bus/TransportProviderFactory'
],
(TransportProviderFactory) ->
  transportProvider = null
  describe 'The transport provider', (done)->
    beforeEach ->
      transportProvider = TransportProviderFactory.getTransportProvider(TransportProviderFactory.TransportProviders.InMemory)

    it 'should not be null', ->
      assert.notEqual(transportProvider, null)