define [
  'jquery'
  'underscore'
  '../../util/Logger'
],
($,_, Logger)->
  class SimpleAuthenticationProvider
    username: null
    password: null
    constructor: (config={})->
      {@username, @password} = config
      unless _.isString @username then @username = 'guest'
      unless _.isString @password then @password = 'guest'

    getCredentials: ->
      deferred = $.Deferred()

      deferred.resolve({username: @username, password: @password})

      return deferred.promise()
