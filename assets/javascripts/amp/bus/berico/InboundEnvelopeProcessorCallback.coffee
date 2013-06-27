define [
  '../../util/Logger'
],
(Logger)->
  class InboundEnvelopeProcessorCallback
    constructor: (@envelopeBus)->
    handleRecieve: (dispatcher)->
      Logger.log.info "InboundEnvelopeProcessorCallback.handleRecieve >> received a message"
      env = dispatcher.envelope
      @envelopeBus.processInbound env
      dispatcher.dispatch env
  return InboundEnvelopeProcessorCallback