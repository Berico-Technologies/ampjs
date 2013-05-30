define [
  'underscore'
],
(_)->
  class EnvelopeDispatcher
    constructor:(@registration, @envelope, @channel)->
    dispatch:(envelope)->
      @dispatch @envelope unless _.isObject envelope
      @registration.handle(envelope)
    dispatchFailed:(envelope, exception)->

  return EnvelopeDispatcher