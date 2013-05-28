define [
  './Response.coffee-compiled'
],
(Response)->
  class Responder
    constructor: (event_type, message)->
      @event_type = event_type
      @message = message
      @response_type = null
      @response_message = null

    @checkResponseNotSet: (responder)->
      if responder.response_type
        throw('Response for ' + responder.message + ' has already been set to ' +
          responder.response_type + ' with ' +  responder.response_message)

    respond: (message)->
      Responder.checkResponseNotSet(@)
      @response_type = 'message'
      @response_message = message
      return @
    fail: (message) ->
      Responder.checkResponseNotSet(@)
      @response_type = 'close'
      @response_message = message
      return @
    match: (request) ->
      return (request.request_type == this.event_type && request.message == this.message)
    response: (client) ->
      return new Response(client, @response_type, @response_message)

  return Responder