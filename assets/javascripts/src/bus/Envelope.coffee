define [
  'underscore'
],
(_)->
  class Envelope
    constructor: ->
      @headers = {}
      @payload = ''
    equals: (obj)->
      return true if obj == @
      return false if _.isNull obj
      return false unless _.isString obj.payload
      return false unless obj.payload == @payload
      return false unless _.isObject obj.headers
      return false unless _.isEqual obj.headers, @headers
      return true
    toString: -> JSON.stringify(@)
    getHeader:(key)-> @headers[key]
    setHeader:(key,value)-> @headers[key] = value
    getHeaders: -> @headers
    getPayload: -> @payload
    setPayload:(@payload)->


  return Envelope