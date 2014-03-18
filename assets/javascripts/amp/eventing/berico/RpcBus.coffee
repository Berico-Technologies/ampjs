define [
  './EventBus'
  '../../util/Logger'
  'uuid'
  '../../bus/Envelope'
  '../../bus/berico/EnvelopeHelper'
  '../../bus/berico/EnvelopeHeaderConstants'
  './RpcRegistration'
  'jquery'
],
(EventBus, Logger, uuid, Envelope, EnvelopeHelper, EnvelopeHeaderConstants, RpcRegistration, $)->
  class RpcBus extends EventBus

    getResponseTo: (config={})->
      {request, timeout, outboundTopic, inboundTopic} = config
      Logger.log.info "RpcBus.getResponseTo >> executing get response"

      deferred = $.Deferred()

      if config.timeout?
        # set a timer to cancel RPC deferred
        timer = setTimeout(
          () ->
            deferred.reject
              error: 'timeout'
          , config.timeout
      )

      requestId = uuid.v4()
      env = @buildRequestEnvelope(requestId, timeout, outboundTopic)

      #build the envelope
      @processOutbound(request, env).then =>

        #create RPC registration
        rpcRegistration = new RpcRegistration({
          requestId: requestId
          expectedTopic: inboundTopic
          inboundChain: @inboundProcessors
        })

        #register with envelope bus
        @envelopeBus.register(rpcRegistration).then =>

          #send the request
          @envelopeBus.send(env)

          #get the response
          rpcRegistration.getResponse().then (data)=>
            #unregister from the bus
            @envelopeBus.unregister(rpcRegistration)
            deferred.resolve(data)
            clearTimeout timer

      return deferred.promise()

    buildRequestEnvelope: (requestId, timeout, expectedTopic)->
      env = new Envelope()
      envelopeHelper = new EnvelopeHelper(env)

      #if specified set the topic and type
      if _.isString expectedTopic
        envelopeHelper.setMessageType expectedTopic
        envelopeHelper.setMessageTopic expectedTopic

      #set the envelope id
      envelopeHelper.setMessageId(requestId)

      #add pattern & timeout information to the headers
      envelopeHelper.setMessagePattern(EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC)
      envelopeHelper.setRpcTimeout(timeout);

      return env
  return RpcBus