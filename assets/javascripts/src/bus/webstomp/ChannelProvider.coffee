define [
  'stomp'
  '../../Logger'
  'sockjs'
  'underscore'
],
(Stomp, Logger, SockJS, _)->
  class ChannelProvider
    @DefaultConnectionStrategy = (exchange) ->
      return "http://#{exchange.hostName}:#{exchange.port}#{exchange.vHost}"

    constructor: (config) ->
      config = config ? {}
      @username = config.username ? "guest"
      @password = config.password ? "guest"
      @connectionPool = {}
      @connectionStrategy = config.connectionStrategy ? ChannelProvider.DefaultConnectionStrategy
      Logger.log.info "ChannelProvider.ctor >> instantiated."
      @connectionFactory = config.connectionFactory ? SockJS

    getConnection: (exchange, callback) ->
      Logger.log.info "ChannelProvider.getConnection >> Getting exchange"
      connectionName = @connectionStrategy(exchange)
      connection = @connectionPool[connectionName]
      if not connection?
        Logger.log.info "ChannelProvider.getConnection >> creating new connection"
        connection = @_createConnection exchange, callback
        @connectionPool[connectionName] = connection
      else
        Logger.log.info "ChannelProvider.getConnection >> returning existing connection"
        callback(connection, true)
    removeConnection: (exchange, callback) ->
      Logger.log.info "ConnectionFactory.removeConnection >> Removing connection"
      connectionName = @connectionStrategy(exchange)
      connection = @connectionPool[connectionName]
      if connection?
        connection.disconnect(_.bind ->
            delete @connectionPool[connectionName]
            callback(true)
          ,this
        )
      else
        callback(false)
    _createConnection: (exchange, callback) ->
      Logger.log.info "ChannelProvider._createConnection >> creating new connection"
      ws = new @connectionFactory(@connectionStrategy(exchange))
      client = Stomp.over(ws)
      client.connect(@username, @password, () -> callback(client, false))
      return client

  return ChannelProvider