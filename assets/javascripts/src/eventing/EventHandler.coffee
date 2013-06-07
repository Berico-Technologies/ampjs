define [], ->
  class EventHandler
    getEventType: ->
      return "EventHandler"
    handle: (arg0, arg1)->
      console.log "EventHandler.handle >> recieved new event to handle"
    handleFailed: (arg0, arg1)->
  return EventHandler