define [
  'amp/factory/ShortBus'
],
(ShortBus)->
  describe 'The Short Bus', ->
    unless testConfig.useEmulatedWebSocket || testConfig.useSimulatedManager
      it 'should allow publishing and subscribing to GTS and failover topics', (done)->
        #note: this is more of an example than a test. it will only work with a real GTS server and web browser
        #and it *should* create its dummy topic since the gts route lookup should fail
        shortBus = ShortBus.getBus({
          publishTopicOverride: "my.cool.topic.123"
          })
        shortBus.subscribe({
          getEventType: ->
            return "my.cool.topic.123"
          handle: (arg0, arg1)->
            assert.equal "interesting stuff", arg0.data
            done()
          handleFailed: (arg0, arg1)->
          }).then ->
            shortBus.publish({data: 'interesting stuff'})