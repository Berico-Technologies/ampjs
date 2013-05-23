define(['underscore', 'stomp', 'test/mock/websocket.mock'], function(_, Stomp, MockWebSocket) {
    describe('just checking', function() {
        it('works for underscore', function(done) {
            var mockWebSocket = new MockWebSocket();
            var client = Stomp.client("ws://mocked/stomp/server");
            var connected = false;
            client.connect('guest','guest',function(){
              done();
            });

        });
    });
});