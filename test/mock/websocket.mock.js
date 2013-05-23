define([], function(){

    var WebSocketMock = function(url) {
      this.url = url;
      this.onclose = function() {};
      this.onopen = function() {};
      this.onerror = function() {};
      this.onmessage = function() {};
      this.readyState = 0;
      this.bufferedAmount = 0;
      this.extensions = '';
      this.protocol = '';
      setTimeout(this.handle_open, 0);
    };

    WebSocketMock.prototype.close = function() {
      this.handle_close();
      return this.readyState = 2;
    };

    WebSocketMock.prototype.send = function(msg) {
      if (this.readyState !== 1) {
        return false;
      }
      this.handle_send(msg);
      return true;
    };

    WebSocketMock.prototype._accept = function() {
      this.readyState = 1;
      return this.onopen({
        'type': 'open'
      });
    };

    WebSocketMock.prototype._shutdown = function() {
      this.readyState = 3;
      return this.onclose({
        'type': 'close'
      });
    };

    WebSocketMock.prototype._error = function() {
      this.readyState = 3;
      return this.onerror({
        'type': 'error'
      });
    };

    WebSocketMock.prototype._respond = function(data) {
      return this.onmessage({
        'type': 'message',
        'data': data
      });
    };

    WebSocketMock.prototype.handle_send = function(msg) {};

    WebSocketMock.prototype.handle_close = function() {};

    WebSocketMock.prototype.handle_open = function() {};

    return WebSocketMock;
})
