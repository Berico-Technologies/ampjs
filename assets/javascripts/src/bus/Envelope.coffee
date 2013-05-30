define [
  'underscore'
],
(_)->
  class Envelope
    headers: {}
    payload: ''

    equals: (obj)->
      return true if obj == @
      return false if _.isNull obj
      return false unless _.isString obj.payload
      return false unless obj.payload == @payload
      return false unless _.isObject obj.headers
      return false unless _.isEqual obj.headers, @headers
      return true
    toString: ->
      JSON.stringify(this)
    getHeader:(key)->
      headers.key
    setHeader:(key,value)->
      headers[key] = value
    getPayload: ->
      payload
  return Envelope