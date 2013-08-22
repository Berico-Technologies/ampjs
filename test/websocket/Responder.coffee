define [
  './Response'
],
(Response)->
  class Responder
    constructor: (event_type, message)->
      @event_type = event_type
      @message = message
      @response_type = null
      @response_message = null

    respond: (message, type)->

      @response_type = type ? 'message'
      @response_message = message
      return @
    fail: (message, type) ->
      Responder.checkResponseNotSet(@)
      @response_type = type ? 'close'
      @response_message = message
      return @
    match: (request) ->
      return (request.request_type == this.event_type && request.message == this.message)
    response: (client) ->
      return new Response(client, @response_type, @response_message)

  return Responder