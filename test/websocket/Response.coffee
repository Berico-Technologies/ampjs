define [], ->
  class Response
    constructor: (client, event_type, message)->
      @type = event_type
      @data = message
      @currentTarget = client

    toString: ->
      status = if (@type == 'open' || @type == 'message') then 'succcess' else 'fail'
      "[ #{status} ] #{@data}"

  return Response