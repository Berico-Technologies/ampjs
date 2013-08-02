define [
  'amp/factory/ShortBus'
],
(ShortBus)->
  describe 'The Short Bus', ->
    unless testConfig.useEmulatedWebSocket || testConfig.useSimulatedManager
      it 'should allow publishing and subscribing to GTS and failover topics', (done)->
        ###
          note: this is more of an example than a test. it will only work with a real GTS server and web browser
          and it *should* create its dummy topic since the gts route lookup should fail

          this example overrides AMP's default SSL-based mutual auth implementation so that you can get a feel for how AMP works without needing to build out unnecessary infrastructure. The implementation below sends usernames, passwords, and message payloads in plain text and should not be used in a production environment.
        ###
        shortBus = ShortBus.getBus({
          publishTopicOverride: "my.cool.topic.123"
          routingInfoConnectionStrategy: (topic)->
            "http://app01:password@#{@hostname}:#{@port}#{@serviceUrlExpression}/#{topic}?c=true"
          exchangeProviderConnectionStrategy: ->
            "http://app01:password@#{@managementHostname}:#{@managementPort}#{@managementServiceUrl}"
          channelProviderConnectionStrategy: (exchange)->
            "http://#{exchange.hostName}:#{exchange.port}#{exchange.vHost}"
          fallbackTopoExchangePort: 15674
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
    unless testConfig.useEmulatedWebSocket || testConfig.useSimulatedManager
      it 'should support ssl-based mutual auth', (done)->
        ###
          this is an example of using AMP *correctly* with ssl and mutual auth
        ###
        shortBus = ShortBus.getBus({
          publishTopicOverride: "my.cool.topic.123"
          exchangeProviderHostname: "gts.archnet.mil"
          routingInfoHostname: "gts.archnet.mil"
          authenticationProviderHostname: "anubis.archnet.mil"
          fallbackTopoExchangeHostname: "rabbit02.archnet.mil"
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
    unless testConfig.useEmulatedWebSocket || testConfig.useSimulatedManager
      it 'should support RPC-based data exchange', (done)->
        @timeout(5000)
        shortBus = ShortBus.getBus({
          publishTopicOverride: "models.CompartmentInfo"
          exchangeProviderHostname: "gts.archnet.mil"
          routingInfoHostname: "gts.archnet.mil"
          authenticationProviderHostname: "anubis.archnet.mil"
          fallbackTopoExchangeHostname: "rabbit02.archnet.mil"
          busType: ShortBus.BUSTYPE.RPC
          })
        shortBus.getResponseTo({data: 'interesting stuff'},1000, "models.CompartmentInfo").then (data)->
          console.log "yay"