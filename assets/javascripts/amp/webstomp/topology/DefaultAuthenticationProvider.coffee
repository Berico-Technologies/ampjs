define [
  'jquery'
  'underscore'
  '../../util/Logger'
],
($,_, Logger)->
  class DefaultAuthenticationProvider
    username: null
    password: null
    constructor: (config={})->
      {@hostname, @port, @serviceUrl, @connectionStrategy} = config
      unless _.isString @hostname then @hostname = 'localhost'
      unless _.isNumber @port then @port = 15679
      unless _.isString @serviceUrl then @serviceUrl = '/anubis/identity/authenticate'
      unless _.isFunction @connectionStrategy then @connectionStrategy = ->
          "https://#{@hostname}:#{@port}#{@serviceUrl}"


    getCredentials: ->
      deferred = $.Deferred()

      if _.isNull(@username) || _.isNull(@password)
        @_authenticate().then =>
          deferred.resolve({username: @username, password: @password})
      else
        deferred.resolve({username: @username, password: @password})

      return deferred.promise()
    getPassword: ->
    _authenticate: ->
      deferred = $.Deferred()

      req = $.ajax
        url: @connectionStrategy()
        dataType: 'jsonp'
      req.done (data, textStatus, jqXHR)=>
          Logger.log.info "DefaultAuthenticationProvider.authenticate >> successfully completed request"
          if _.isObject data
            @username = data.identity if _.isString data.identity
            @password = data.token if _.isString data.token
            deferred.resolve(data)
          else deferred.reject()
      req.fail (jqXHR, textStatus, errorThrown)->
          Logger.log.error "DefaultAuthenticationProvider.authenticate >> failed complete request"
          deferred.reject()

      return deferred.promise()
  return DefaultAuthenticationProvider