define [
  'stomp'
  '../../Logger'
  'sockjs'
  'underscore'
],
(Stomp, Logger, SockJS, _)->
  class ChannelProvider
    @DefaultConnectionStrategy = (route) ->
      return "http://#{route.host}:#{route.port}#{route.vhost}#{route.exchange}"

    constructor: (config) ->
      config = config ? {}
      @username = config.username ? "guest"
      @password = config.password ? "guest"
      @connectionPool = {}
      @connectionStrategy = config.connectionStrategy ? ChannelProvider.DefaultConnectionStrategy
      Logger.log.info "ChannelProvider.ctor >> instantiated."
      @connectionFactory = config.connectionFactory ? SockJS

    getConnection: (route, dedicated, callback) ->
      Logger.log.info "ChannelProvider.getConnection >> Getting route"
      connectionName = @connectionStrategy(route)
      connection = @connectionPool[connectionName]
      if dedicated or not connection?
        Logger.log.info "ChannelProvider.getConnection >> creating new connection"
        connection = @_createConnection route, callback
        @connectionPool[connectionName] = connection unless dedicated
      else
        Logger.log.info "ChannelProvider.getConnection >> returning existing connection"
        callback(connection, true)
    removeConnection: (route, callback) ->
      Logger.log.info "ConnectionFactory.removeConnection >> Removing connection"
      connectionName = @connectionStrategy(route)
      connection = @connectionPool[connectionName]
      if connection?
        connection.disconnect(_.bind ->
            delete @connectionPool[connectionName]
            callback(true)
          ,this
        )
      else
        callback(false)
    getChannelFor: () ->
    _createConnection: (route, callback) ->
      Logger.log.info "ChannelProvider._createConnection >> creating new connection"
      ws = new @connectionFactory(@connectionStrategy(route))
      client = Stomp.over(ws)
      client.connect(@username, @password, () -> callback(client, false))
      return client

  return ChannelProvider