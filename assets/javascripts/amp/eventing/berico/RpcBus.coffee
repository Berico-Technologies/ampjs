define [
  './EventBus'
  '../../util/Logger'
  './ProcessingContext'
  'uuid'
  '../../bus/Envelope'
  '../../bus/berico/EnvelopeHelper'
  '../../bus/EnvelopeHeaderConstants'
  './RpcRegistration'
  'jquery'
],
(EventBus, Logger, ProcessingContext, uuid, Envelope, EnvelopeHelper, EnvelopeHeaderConstants, RpcRegistration, $)->
  class RpcBus extends EventBus

    getResponseTo: (request, timeout, expectedTopic)->
      Logger.log.info "RpcBus.getResponseTo >> executing get response"

      deferred = $.Deferred()
      requestId = uuid.v4()
      env = @buildRequestEnvelope(requestId, timeout)

      #build the envelope
      @processOutbound(request, env).then =>

        #create RPC registration
        rpcRegistration = new RpcRegistration({
          requestId: requestId
          expectedTopic: expectedTopic
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

      return deferred.promise()

    buildRequestEnvelope: (requestId, timeout)->
      env = new Envelope()
      envelopeHelper = new EnvelopeHelper(env)

      #set the envelope id
      envelopeHelper.setMessageId(requestId)

      #add pattern & timeout information to the headers
      envelopeHelper.setMessagePattern(EnvelopeHeaderConstants.MESSAGE_PATTERN_RPC)
      envelopeHelper.setRpcTimeout(timeout);

      return env
  return RpcBus