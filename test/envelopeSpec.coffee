define [
  'underscore'
  'src/bus/Envelope'
  'src/bus/EnvelopeHeaderConstants'
],
(_,Envelope, EnvelopeHeaderConstants) ->
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

      assert.equal '{"payload":"payload"}', envelope.toString()