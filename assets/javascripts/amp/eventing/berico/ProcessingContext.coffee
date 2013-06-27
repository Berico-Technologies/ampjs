define [], ->
  class ProcessingContext
    properties: {}
    constructor: (@env, @event)->
    getEnvelope: -> @env
    getEvent: -> @event
    getProperty: (key)-> @properties[key]
    setEnvelope: (env)-> @env = env
    setEvent: (event)-> @event = event
    setProperties: (@properties)->
    setProperty: (key, value)-> @properties[key]=value
  return ProcessingContext