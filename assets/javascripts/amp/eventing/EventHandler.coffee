define [
  '../util/Logger'
],
(Logger)->
  class EventHandler
    getEventType: ->
      return "EventHandler"
    handle: (arg0, arg1)->
      Logger.log.info "EventHandler.handle >> recieved new event to handle"
    handleFailed: (arg0, arg1)->
  return EventHandler