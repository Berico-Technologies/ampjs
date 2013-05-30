define [], ->
  class EventHandler
    getEventType: ->
      return "EventHandler"
    handle: (arg0, arg1)->
    handleFailed: (arg0, arg1)->
  return EventHandler