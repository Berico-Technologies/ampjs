define [
  'underscore'
  'amp/bus/Envelope'
  'amp/bus/berico/EnvelopeHeaderConstants'
  'amp/bus/berico/EnvelopeHelper'
],
(_,Envelope, EnvelopeHeaderConstants, EnvelopeHelper) ->
  describe 'The Envelope', ->
    it 'should not be null', ->
      envelope = new Envelope()
      assert.notEqual null, envelope

    it 'should test equality correctly', ->
      envelope1 = new Envelope()
      envelope1.headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = "mytopic"
      envelope1.payload = 'payload'

      envelope2 = new Envelope()
      envelope2.headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = "mytopic"
      envelope2.payload = 'payload'

      envelope3 = new Envelope()

      envelope4 = new Envelope()
      envelope4.headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = "myOTHERtopic"
      envelope4.payload = 'OTHERpayload'

      assert.equal true, envelope1.equals(envelope2)
      assert.notEqual true, envelope1.equals(envelope3)
      assert.notEqual true, envelope1.equals(envelope4)

    it 'should support toString', ->
      envelope = new Envelope()
      envelope.headers[EnvelopeHeaderConstants.MESSAGE_TOPIC] = "mytopic"
      envelope.payload = 'payload'

      assert.equal '{"headers":{"cmf.bus.message.topic":"mytopic"},"payload":"payload"}', envelope.toString()

    it 'should allow you to set the payload', ->
      envelope = new Envelope()
      payload = "i am a payload"
      envelope.setPayload payload
      assert.equal payload, envelope.getPayload()

  describe 'The EnvelopeHelper',->
    it 'should accept an envelope and let you set properties',->
      payload = "i'm a payload, isn't that nice?"
      messageId = uuid.v1()
      messageType = "messageType"
      messageTopic = "messageTopic"
      senderIdentity = "dtayman"

      envelope = new Envelope()
      envelope.setPayload(payload)
      env = new EnvelopeHelper(envelope)
      env.setMessageId(messageId);
      env.setMessageType(messageType);
      env.setMessageTopic(messageTopic);
      env.setSenderIdentity(senderIdentity);

      assert.equal payload, env.getPayload()
      assert.equal messageId, env.getMessageId()
      assert.equal messageType, env.getMessageType()
      assert.equal messageTopic, env.getMessageTopic()
      assert.equal senderIdentity, env.getSenderIdentity()
