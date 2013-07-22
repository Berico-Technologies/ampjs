define([], function() {
  var EventHandler;
  EventHandler = (function() {
    function EventHandler() {}

    EventHandler.prototype.getEventType = function() {
      return "EventHandler";
    };

    EventHandler.prototype.handle = function(arg0, arg1) {
      return console.log("EventHandler.handle >> recieved new event to handle");
    };

    EventHandler.prototype.handleFailed = function(arg0, arg1) {};

    return EventHandler;

  })();
  return EventHandler;
});
