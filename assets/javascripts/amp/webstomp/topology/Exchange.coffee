define [
  'jshashes'
],
(Hashes) ->
  class Exchange
    constructor: (@name, @hostName, @vHost, @port, @routingKey, @queueName, @exchangeType, @isDurable, @isAutoDelete, @arguments)->

    toString: ->
      "{Name: #{@name}, HostName: #{@hostName}, VirtualHost: #{@vHost}, Port: #{@port}, RoutingKey: #{@routingKey}, Queue Name: #{@queueName}, ExchangeType: #{@exchangeType}, IsDurable: #{@isDurable}, IsAutoDelete: #{@isAutoDelete}}"

    hashCode: ->
      new Hashes.MD5(@toString).hex()

    equals: (input)->
      return false unless _.isObject input
      return false if input.name != @name
      return false if input.hostName != @hostName
      return false if input.vHost != @vHost
      return false if input.port != @port
      return true
  return Exchange