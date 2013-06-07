define [
  '../Logger'
],
(Logger)->
  class InboundEnvelopeRecievedCallback
    constructor: (@envelopeBus)->
    handleRecieve: (dispatcher)->
      Logger.log.info "InboundEnvelopeRecievedCallback.handleRecieve >> received a message"
      env = dispatcher.envelope
      @envelopeBus.processInbound env
      dispatcher.dispatch env
  return InboundEnvelopeRecievedCallback