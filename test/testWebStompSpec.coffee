define [
  'underscore'
  'stomp'
  'test/mock/server.mock.coffee-compiled'
],
(_, Stomp, StompServerMock) ->
  describe 'MockWebsocket', ->
    it 'needs to be able to create a client', (done) ->
      ws = new StompServerMock("ws://mocked/stomp/server")
      client = Stomp.over(ws)
      connected = false
      client.connect("guest", "guest", ->
        done()
      )


