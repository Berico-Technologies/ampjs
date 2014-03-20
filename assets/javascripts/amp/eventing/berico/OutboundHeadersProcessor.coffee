define [
  '../../bus/berico/EnvelopeHelper'
  'uuid'
  'underscore'
  '../../util/Logger'
  '../../connection/topology/DefaultAuthenticationProvider'
  'jquery'
],
(EnvelopeHelper, uuid, _, Logger, DefaultAuthenticationProvider,$)->
  class OutboundHeadersProcessor
    userInfoRepo: null

    constructor: (config={})->
      {@authenticationProvider}=config

      unless _.isObject @authenticationProvider then @authenticationProvider = new DefaultAuthenticationProvider()

    processOutbound: (context)->

      deferred = $.Deferred()
      outboundDeferreds = []

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

      outboundDeferreds.push @getAnubisCredentials(env.getSenderIdentity(), env.getSenderAuthToken()).done (credentials)->
        env.setSenderIdentity credentials.username
        env.setSenderAuthToken credentials.token

      $.when.apply($,outboundDeferreds).then(
        () ->
          deferred.resolve()
        () ->
          deferred.reject {error: 'OutboundHeadersProcessor.processOutbound >> error in outbound processors', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
      )

      return deferred.promise()

    getAnubisCredentials: (username, token)->
      deferred = $.Deferred()
      if (_.isString username) && (_.isString token)
        Logger.log.info "OutboundHeadersProcessor.getUsername >> using username from envelope: #{username}"
        deferred.resolve
          username: username
          token: token
      else
        @authenticationProvider.getCredentials().then(
          (data)->
            Logger.log.info "OutboundHeadersProcessor.getUsername >> using username from authenticationProvider: #{data.username}"
            deferred.resolve
              username: data.username
              token: data.password
          () ->
            deferred.reject {error: 'OutboundHeadersProcessor.getUsername >> error in authenticationProvider.getCredentials', cause: if arguments.length is 1 then arguments[0] else $.extend({}, arguments)}
        )
      return deferred.promise()
    getMessageType: (event)->
      type = Object.getPrototypeOf(event).constructor.name
      Logger.log.info "OutboundHeadersProcessor.getMessageType >> inferring type as #{type}"
      return type
    getMessageTopic: (event)->
      type = Object.getPrototypeOf(event).constructor.name
      Logger.log.info "OutboundHeadersProcessor.getMessageTopic >> inferring topic as #{type}"
      return type
  return OutboundHeadersProcessor