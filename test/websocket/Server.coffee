define [
  './Request.coffee-compiled'
  './Responder.coffee-compiled'
  'amp/util/Logger'
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
        Logger.log.info 'Server.request >> found responder for request'
        response = responder.response request.client

      else
        Logger.log.info 'Server.request >> could not find responder - using builtin'
        switch request.request_type
          when 'open' then response = new Response request.client, 'open'
          when 'close' then response = new Response request.client, 'close'
          else response = new Response request.client, '[Server] No response configured for '+request.request_type

      callback response

    match: (url) ->
      return url == @url

    findResponder: (request) ->
      _.find @responders, (responder)-> responder.match(request)

    @servers = []
    @configure: (url, config) ->
      server = @find(url)
      unless _.isObject server
        server = new Server(url)
        Server.servers.push server

      config.apply(server,[])

      return server
    @find: (url) ->
      _.find Server.servers, (server)-> server.match(url)
  return Server