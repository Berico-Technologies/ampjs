define [
  'jquery'
  'underscore'
  '../../util/Logger'
  './DefaultAuthenticationProvider'
  'jsonp'
],
($,_, Logger, DefaultAuthenticationProvider)->
  class DefaultIdentityProvider

    constructor: (config={})->
      {@hostname, @port, @serviceUrl, @connectionStrategy, @authenticationProvider} = config
      unless _.isString @hostname then @hostname = 'localhost'
      unless _.isNumber @port then @port = 15679
      unless _.isString @serviceUrl then @serviceUrl = '/anubis/x509/identity'
      unless _.isFunction @connectionStrategy then @connectionStrategy = ->
          "https://#{@hostname}:#{@port}#{@serviceUrl}"
      unless _.isObject @authenticationProvider then @authenticationProvider = new DefaultAuthenticationProvider()


    getIdentity: (topic = "")->

      deferred = $.Deferred()

      req = $.jsonp(
        url: @connectionStrategy()
        callbackParameter: 'callback'
        data:
          topic: topic
          operation: "PRODUCE"
      ).then(
        (data, textStatus, jqXHR)=>
          Logger.log.info "DefaultIdentityProvider.getIdentity >> successfully completed request"
          if _.isObject data
            deferred.resolve(data)
          else deferred.reject()
        ()->
          Logger.log.error "DefaultIdentityProvider.getIdentity >> failed complete request"
          deferred.reject if arguments.length > 1 then Array.prototype.slice.call(arguments, 0) else arguments[0]
      )

      return deferred.promise()
  return DefaultIdentityProvider