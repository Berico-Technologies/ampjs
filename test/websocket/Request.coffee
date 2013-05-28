define [], ->
  class Request
    constructor: (client, request_type, message) ->
      @client = client
      @request_type = request_type
      @message = message
    toString: ->
        return "[Request] "+@request_type+ ' : '+@message
  return Request