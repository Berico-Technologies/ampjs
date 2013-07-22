define [
  'amp/util/Logger'
  './Request.coffee-compiled'
  './Server.coffee-compiled'
  'underscore'
],
(Logger, Request, Server, _)->
  class Client
    @clients
    constructor: (url)->
      @__server = null
      @readyState = 0

      setTimeout(_.bind(@connect, @, url) ,100)

    onmessage: (evt)->
      Logger.log.info 'Client.onmessage'
    onclose: (evt)->
      Logger.log.info 'Client.onclose'
    onopen: (evt)->
      Logger.log.info 'Client.onopen'

    close: ->
      @readyState = 2
      request = new Request @,'close'
      @__server.request request, _.bind(@dispatch,@)

    send: (message)->
      Logger.log.info "Client.send >> sending message"
      return false if @readyState != 1
      request = new Request @, 'message', message
      @__server.request request, _.bind(@dispatch,@)
      return true

    dispatch: (response)->
      switch response.type
        when 'open' then @readyState=1
        when 'close' then @readyState=3
      @['on'+response.type](response) if _.isFunction @['on'+response.type]

    connect: (url)->
      @__server = Server.find(url)
      throw '[Client] No server configured for '+url unless @__server?
      request = new Request(@, 'open')
      @__server.request(request, _.bind(@dispatch,@))


  return Client