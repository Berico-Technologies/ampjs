define [
  'jquery'
  'underscore'
  '../../util/Logger'
],
($,_, Logger)->
  class DefaultIdentityProvider

    constructor: (config={})->
      {@hostname, @port, @serviceUrl, @connectionStrategy} = config
      unless _.isString @hostname then @hostname = 'localhost'
      unless _.isNumber @port then @port = 15679
      unless _.isString @serviceUrl then @serviceUrl = '/anubis/identity/identify'
      unless _.isFunction @connectionStrategy then @connectionStrategy = ->
          "https://#{@hostname}:#{@port}#{@serviceUrl}"


    getIdentity: (topic = "")->

      deferred = $.Deferred()

      req = $.ajax
        url: @connectionStrategy()
        dataType: 'jsonp'
        data: topic
      req.done (data, textStatus, jqXHR)=>
          Logger.log.info "DefaultIdentityProvider.getIdentity >> successfully completed request"
          if _.isObject data
            deferred.resolve(data)
          else deferred.reject()
      req.fail (jqXHR, textStatus, errorThrown)->
          Logger.log.error "DefaultIdentityProvider.getIdentity >> failed complete request"
          deferred.reject()

      return deferred.promise()
  return DefaultIdentityProvider