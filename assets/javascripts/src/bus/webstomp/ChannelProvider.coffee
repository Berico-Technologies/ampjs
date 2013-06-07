define [
  'stomp'
  '../../Logger'
  'sockjs'
  'underscore'
  'jquery'
],
(Stomp, Logger, SockJS, _, $)->
  class ChannelProvider
    @DefaultConnectionStrategy = (exchange) ->
      return "http://#{exchange.hostName}:#{exchange.port}#{exchange.vHost}"

    constructor: (config) ->
      config = config ? {}
      @username = if _.isString config.username then config.username else "guest"
      @password = if _.isString config.password then config.password else "guest"
      @connectionPool = {}
      @connectionStrategy = config.connectionStrategy ? ChannelProvider.DefaultConnectionStrategy
      Logger.log.info "ChannelProvider.ctor >> instantiated."
      @connectionFactory = if _.isFunction config.connectionFactory then config.connectionFactory else SockJS

    getConnection: (exchange) ->
      deferred = $.Deferred()
      Logger.log.info "ChannelProvider.getConnection >> Getting exchange"
      connectionName = @connectionStrategy(exchange)
      connection = @connectionPool[connectionName]
      if not connection?
        Logger.log.info "ChannelProvider.getConnection >> creating new connection"
        @_createConnection exchange, deferred
        deferred.then (connection)=>
          @connectionPool[connectionName] = connection

      else
        Logger.log.info "ChannelProvider.getConnection >> returning existing connection"
        deferred.resolve(connection, true)

      return deferred.promise()

    removeConnection: (exchange) ->
      deferred = $.Deferred()
      Logger.log.info "ConnectionFactory.removeConnection >> Removing connection"
      connectionName = @connectionStrategy(exchange)
      connection = @connectionPool[connectionName]
      if connection?
        connection.disconnect(=>
            delete @connectionPool[connectionName]
            deferred.resolve true
        )
      else
        deferred.reject false

    _createConnection: (exchange, deferred) ->
      Logger.log.info "ChannelProvider._createConnection >> creating new connection"
      ws = new @connectionFactory(@connectionStrategy(exchange))
      client = Stomp.over(ws)
      client.connect(@username, @password,
        ->
          deferred.resolve client, false
        ,(err)->
          errorMessage = "ChannelProvider._createConnection >> #{err}"
          deferred.reject errorMessage
          Logger.log.error errorMessage
        )
      return deferred.promise()


    dispose: ()->
      disposeDeferred = $.Deferred()
      disposeDeferredCollection = []

      for connection in @connectionPool
        connectionDeferred = $.Deferred()
        disposeDeferredCollection.push(connectionDeferred)
        connection.disconnect(->
          connectionDeferred.resolve()
        )

      $.when(disposeDeferredCollection).done ->
        disposeDeferred.resolve()

      return disposeDeferred

  return ChannelProvider