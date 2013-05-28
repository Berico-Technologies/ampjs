define [
  './Request.coffee-compiled'
  './Responder.coffee-compiled'
  'src/Logger'
  'underscore'
  './Response.coffee-compiled'
],
(Request, Responder, Logger, _, Response)->
  class Server

    constructor: (url) ->
      @url = url
      @responders = []

    addResponder: (type, msg) ->
      responder = new Responder(type, msg)
      @responders.push responder
      return responder

    onmessage: (message) ->
      @addResponder 'message', message

    onconnect: ->
      @addResponder 'open', ''

    request: (request, callback) ->
      response = null
      if responder = @findResponder(request)
        response = responder.response request.client

      else
        switch request.request_type
          when 'open' then response = new Response request.client, 'open'
          when 'close' then response = new Response request.client, 'close'
          else response = new Response request.client, '[Server] No response configured for '+request.request_type

      Logger.log.info '[InMemory Server] '+request.toString()+' => '+response.toString()
      callback response

    match: (url) ->
      return url == @url

    findResponder: (request) ->
      _.find @responders, (responder)-> responder.match(request)

    @servers = []
    @configure: (url, config) ->
      server = new Server(url)
      config.apply(server,[])
      Server.servers.push server
      return server
    @find: (url) ->
      _.find Server.servers, (server)-> server.match(url)
  return Server