define [
  'stomp'
  '../util/Logger'
  'sockjs'
  'underscore'
  'jquery'
  './topology/DefaultAuthenticationProvider'
],
(Stomp, Logger, SockJS, _, $, DefaultAuthenticationProvider)->
  class ChannelProvider
    @DefaultConnectionStrategy = (exchange) ->
      return "https://#{exchange.hostName}:#{exchange.port}#{exchange.vHost}"

    connectionPool: {}
    constructor: (config={}) ->

      {@connectionStrategy, @connectionFactory, @authenticationProvider, @messagingFactory} = config
      unless _.isFunction @connectionStrategy then @connectionStrategy = ChannelProvider.DefaultConnectionStrategy
      unless _.isFunction @connectionFactory then @connectionFactory = SockJS
      unless _.isFunction @messagingFactory then @messagingFactory = (ws)->
        Stomp.over(ws)
      unless _.isObject @authenticationProvider then @authenticationProvider = new DefaultAuthenticationProvider()
      Logger.log.info "ChannelProvider.ctor >> instantiated."


    getConnection: (exchange) ->
      deferred = $.Deferred()
      Logger.log.info "ChannelProvider.getConnection >> Getting exchange"
      connectionName = @connectionStrategy(exchange)
      connection = @connectionPool[connectionName]
      if not connection?
        Logger.log.info "ChannelProvider.getConnection >> could not find existing connection"
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
      Logger.log.info "ChannelProvider._createConnection >> attempting to create a new connection"
      @authenticationProvider.getCredentials().then (credentials)=>
        {username, password} = credentials
        ws = new @connectionFactory(@connectionStrategy(exchange))
        client = @messagingFactory(ws)
        #rabbit does not support heartbeat in stomp 1.1, you need to set this to 0
        #or the connection will die after the first timeout
        client.heartbeat =
          outgoing: 0
          incoming: 0
        client.connect(username,password,
          ->
            Logger.log.info "ChannelProvider._createConnection >> successfully connected"
            deferred.resolve client, false
          ,(err)->
            errorMessage = "ChannelProvider._createConnection >> #{err}"
            Logger.log.error "ChannelProvider._createConnection >> unable to connect: #{err}"
            deferred.reject errorMessage
            Logger.log.error errorMessage
          )
        return deferred.promise()


    dispose: ()->
      Logger.log.info "ChannelProvider.dispose >> clearing connections"
      disposeDeferred = $.Deferred()
      disposeDeferredCollection = []

      for connection in @connectionPool
        connectionDeferred = $.Deferred()
        disposeDeferredCollection.push(connectionDeferred)
        connection.disconnect(->
          connectionDeferred.resolve()
        )

      $.when.apply($,disposeDeferredCollection).done ->
        disposeDeferred.resolve()

      return disposeDeferred.promise()

  return ChannelProvider