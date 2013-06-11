define [
  'underscore'
  '../util/Logger'
],
(_, Logger)->
  class EnvelopeDispatcher
    constructor:(@registration, @envelope, @channel)->
    dispatch:(envelope)->
      Logger.log.info "EnvelopeDispatcher.dispatch >> dispatching envelope"
      @dispatch @envelope unless _.isObject envelope
      @registration.handle(envelope)
    dispatchFailed:(envelope, exception)->

  return EnvelopeDispatcher