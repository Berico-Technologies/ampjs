define(['underscore'], function(_) {
  var Envelope;
  Envelope = (function() {
    function Envelope(headers, payload) {
      this.headers = headers != null ? headers : {};
      this.payload = payload != null ? payload : '';
    }

    Envelope.prototype.equals = function(obj) {
      if (obj === this) {
        return true;
      }
      if (_.isNull(obj)) {
        return false;
      }
      if (!_.isString(obj.payload)) {
        return false;
      }
      if (obj.payload !== this.payload) {
        return false;
      }
      if (!_.isObject(obj.headers)) {
        return false;
      }
      if (!_.isEqual(obj.headers, this.headers)) {
        return false;
      }
      return true;
    };

    Envelope.prototype.toString = function() {
      return JSON.stringify(this);
    };

    Envelope.prototype.getHeader = function(key) {
      return this.headers[key];
    };

    Envelope.prototype.setHeader = function(key, value) {
      return this.headers[key] = value;
    };

    Envelope.prototype.getHeaders = function() {
      return this.headers;
    };

    Envelope.prototype.getPayload = function() {
      return this.payload;
    };

    Envelope.prototype.setPayload = function(payload) {
      this.payload = payload;
    };

    return Envelope;

  })();
  return Envelope;
});
