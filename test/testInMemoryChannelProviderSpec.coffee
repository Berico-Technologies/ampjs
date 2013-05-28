define [
],
() ->
  # channelProvider = null
  # describe 'The inmemory channel provider', (done)->
  #   beforeEach ->
  #     channelProvider = new ChannelProvider()

  #   it 'should not be null', ->
  #     assert.notEqual channelProvider, null

  #   it 'should execute the getConnection callback', (done) ->
  #     callback = (client, existing) ->
  #       assert.notEqual client, null
  #       assert.ok !existing
  #       done()
  #     channelProvider.getConnection("test", false, callback)

  #   it 'lets you subscribe and publish', (done) ->


  #     callback = (client, existing) ->
  #       message = "Are you the Keymaster?"
  #       client.subscribe("/queue/test", (output) ->
  #         assert.Equal message, output
  #         done()
  #         )
  #       client.send("/queue/test", {}, message)

  #     route = "test"
  #     channelProvider.getConnection("test", false, callback)




