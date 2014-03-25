define [
  'jquery'
  'underscore'
  '../../util/Logger',
  'jsonp'
],
($,_, Logger)->
  class DefaultAuthenticationProvider
    username: null
    password: null
    constructor: (config={})->
      {@hostname, @port, @serviceUrl, @connectionStrategy} = config
      unless _.isString @hostname then @hostname = 'localhost'
      unless _.isNumber @port then @port = 15679
      unless _.isString @serviceUrl then @serviceUrl = '/anubis/x509/authenticate'
      unless _.isFunction @connectionStrategy then @connectionStrategy = ->
          "https://#{@hostname}:#{@port}#{@serviceUrl}"

    getCredentials: ->
      deferred = $.Deferred()

      if _.isNull(@username) || _.isNull(@password)
        @_authenticate().then(
          () =>
            deferred.resolve({username: @username, password: @password})
          () ->
            deferred.reject {error: 'DefaultAuthenticationProvider.getCredentials >> error authenticating', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
        )
      else
        deferred.resolve({username: @username, password: @password})

      return deferred.promise()

    _authenticate: ->
      deferred = $.Deferred()

      $.jsonp(
        url: @connectionStrategy()
        callbackParameter: 'callback'
      ).then(
        (data, textStatus, jqXHR)=>
          Logger.log.info "DefaultAuthenticationProvider.authenticate >> successfully completed request"
          if _.isObject data
            if data.authenticationToken?
              # new x509 endpoint
              @username = data.authenticationToken.identity if _.isString data.authenticationToken.identity
              @password = data.authenticationToken.key if _.isString data.authenticationToken.key
              deferred.resolve(data)
            else
              # backwards-compatible for old identity endpoint
              @username = data.identity if _.isString data.identity
              @password = data.token if _.isString data.token
              deferred.resolve(data)
          else
            deferred.reject {error: 'DefaultAuthenticationProvider._authenticate >> unexpected response: expecting an object'}
        ()->
          Logger.log.error "DefaultAuthenticationProvider.authenticate >> failed complete request"
          deferred.reject {error: 'DefaultAuthenticationProvider._authenticate >> failed', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
      )

      return deferred.promise()

  return DefaultAuthenticationProvider