define [
  '../../bus/berico/EnvelopeHelper'
  'uuid'
  'underscore'
  '../../util/Logger'
],
(EnvelopeHelper, uuid, _, Logger)->
  class OutboundHeadersProcessor
    userInfoRepo: null

    constructor: (@userInfoRepo)->

    processOutbound: (context)->
      Logger.log.info "OutboundHeadersProcessor.processOutbound >> adding headers"
      env = new EnvelopeHelper(context.getEnvelope())

      messageId = if _.isString env.getMessageId() then env.getMessageId() else uuid.v4()
      env.setMessageId(messageId)

      correlationId = env.getCorrelationId()

      messageType = env.getMessageType()
      messageType = if _.isString messageType then messageType else @getMessageType context.getEvent()
      env.setMessageType messageType

      messageTopic = env.getMessageTopic()
      messageTopic = if _.isString messageTopic then messageTopic else @getMessageTopic context.getEvent()
      env.setMessageTopic messageTopic

      senderIdentity = env.getSenderIdentity()
      senderIdentity = if _.isString senderIdentity then senderIdentity else "unknown"
      env.setSenderIdentity senderIdentity

    getMessageType: (event)->
      type = Object.getPrototypeOf(event).constructor.name
      Logger.log.info "OutboundHeadersProcessor.getMessageType >> inferring type as #{type}"
      return type
    getMessageTopic: (event)->
      type = Object.getPrototypeOf(event).constructor.name
      Logger.log.info "OutboundHeadersProcessor.getMessageTopic >> inferring topic as #{type}"
      return type
  return OutboundHeadersProcessor