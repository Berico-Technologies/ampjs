define([], function() {
  var ProcessingContext;
  ProcessingContext = (function() {
    ProcessingContext.prototype.properties = {};

    function ProcessingContext(env, event) {
      this.env = env;
      this.event = event;
    }

    ProcessingContext.prototype.getEnvelope = function() {
      return this.env;
    };

    ProcessingContext.prototype.getEvent = function() {
      return this.event;
    };

    ProcessingContext.prototype.getProperty = function(key) {
      return this.properties[key];
    };

    ProcessingContext.prototype.setEnvelope = function(env) {
      return this.env = env;
    };

    ProcessingContext.prototype.setEvent = function(event) {
      return this.event = event;
    };

    ProcessingContext.prototype.setProperties = function(properties) {
      this.properties = properties;
    };

    ProcessingContext.prototype.setProperty = function(key, value) {
      return this.properties[key] = value;
    };

    return ProcessingContext;

  })();
  return ProcessingContext;
});
