define [
  'underscore'
  'amp/eventing/berico/handlers/EncryptedRequestHandler'
  'amp/eventing/berico/handlers/EncryptedResponseHandler'
  'amp/connection/topology/DefaultMessagingKeystore'
  'uuid'
  'amp/bus/Envelope'
  'amp/bus/berico/EnvelopeHeaderConstants'
  'amp/bus/berico/EnvelopeHelper'
  'amp/eventing/berico/ProcessingContext'
  'amp/factory/ShortBus'
  'jquery'
  'amp/util/AesUtil'
],
(_,EncryptedRequestHandler, EncryptedResponseHandler, DefaultMessagingKeystore, uuid, Envelope, EnvelopeHeaderConstants, EnvelopeHelper, ProcessingContext, ShortBus, $, AesUtil) ->
  describe 'The EncryptionHandlers and Keystore', ->
    defaultMessagingKeystore = null
    encryptedRequestHandler = null
    encryptedResponseHandler = null
    stompStub = null
    $ = $
    beforeEach ->
      $.ajax = (options)->
        deferred = $.Deferred()
        if /anubis.archnet.mil:15679\/anubis\/identity\/authenticate*/.test options.url
          deferred.resolve
            token: "ILUXUSHYQW21OqGK+JMvzw=="
            identity: "CN=Drew Tayman, CN=Users, DC=archnet, DC=mil"
        else if /anubis.archnet.mil:15679\/anubis\/identity\/identify*/.test options.url
          deferred.resolve
            privateKey: """
                        -----BEGIN RSA PRIVATE KEY-----
                        MIIEpAIBAAKCAQEAwaj+LfZxDy1zWySmRvg/Jo8eOhsScjnxGd21tvz+ijBCj9BG
                        oeXqLRFDxsZINIvYkWMzdtUbYGOlPRJUHLjYyY4aXLkbgP6eyvJYHmLLNqmjJlxC
                        AEqQahEJ0BEcIuJKmJ8w603DggXJ3QAjruZfzfBMZ9fn915c6TeuKLvja6fyM5xH
                        KXngHdnHJ5nuN0wvJnJKa5Y6Ju+M5SiVU2TRv4ctVcoU9ZM7mBYeiq9goYsMtNqy
                        JY+TgX2ysf0ryMogRvdYOdsSFbEOTYPtp2JM3qo+Y8axO5AV3FEBr92U5KCKxhc8
                        2j4s2g9mtZDIO4iPFWYp8spOcCGtmRww8ErWxQIDAQABAoIBAQCcgFc5CamAXHiW
                        tV1yiPdvz8TbrDkR+mUvRA6vnHCPeESyN9x8xXKjjQo6vs5nOISBqatTYxDGqoBE
                        hGVY+MCo0Z/YQvdJHXtyArrXg3s554kjXPcxiRB/xtkpPkqAnmMuR6ee4K8YilkB
                        sjUkCKRvprv4R3D8ZVOsXQTvgjddLWfBn+Fa6BIAw2fJiZmD7NvuGkY3s9AzfuK+
                        yvgjmhHqdop420PQzPh8SDrE9P9pvMaBkD1ieanCBpIdMTlpOEceEr0hX8Uo1wTF
                        acx+3TtHBi+U3PN6r1ps5ME26vRd/77oJe4y8Ud2BO6EOcgFxOW1QtivA+oqw2SI
                        3rFQiwCBAoGBAPmaRRQZywlx/REP9D+wxnJPu0mLkpwkvvAfxNkuHst9r8mnJmhJ
                        bGWrU7zCC18UfuTJ6gMGqnTrYfPnZ373VEJErhv5+GK9vYX4mox9dTwIdq67i9WK
                        PAOXLeK5nYlwDEEpk54w89DcgGtNUDqUpQ7p0YoyMpDk/ID+z2K3DJVRAoGBAMaf
                        qjBF9UA3CRxPV/EbRX/EBG1mfvQFndUdGjraLUdJXrevMRC4GMD6uaDCskXxkTcw
                        wP2bKcaMNRyTNqluuFQOA2IbLxyyfBrAKuyhfh0GpZp9N60MuBf4+2qye0UnqmRt
                        05/u41BEdOggAcXKyeKD1yUiAd9ACsHCJIpS+d01AoGBAL/mHYnwsqsWWixOCckV
                        zdyA9Er85cDqd2oB4sPes4pbnVT6D4tKN+6KpByRS1DUXyLjIeklrNOrTGnK1UVG
                        Ph+c0gdsTc0Md7OSiK/OnN2E3EpGoqGQX8ea6YpQjo/l92X54yZSGIHRpWHZ1P7U
                        3Xnzxkfrg/jmNEOwpB0PAruhAoGAG17PLf3F8QZkfAE3BiOS7StOzOCN6ASKHl73
                        SVrdWHB02+0JXttvldA3Gj8aH+dM8oUGYywpkpGpk/l5U9nNDtAriS5jzJmP3oPS
                        pm8OmONcmLBeprsU90C5LJfRwtLXeSVlPynFKz9zuLUIaYArV8qBMD3Cckg58z9U
                        l7cddW0CgYBqbqopQK11vC65JBZJux+DlCHV34ebqxY+0wi56ef9r9FDj2vJu6Db
                        6fKW2daql0hoCC39VHNZUpUD00NMgfTy01zQsl8MngPrP7O9u84NeC3+XK1Ly++v
                        LoKsTltfkE5SqXJq5Ng4Z31ouPv1pOwsnnSdlMdko33qQ6mzV490vg==
                        -----END RSA PRIVATE KEY-----
                      """
            publicKey: """
                      -----BEGIN PUBLIC KEY-----
                      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwaj+LfZxDy1zWySmRvg/
                      Jo8eOhsScjnxGd21tvz+ijBCj9BGoeXqLRFDxsZINIvYkWMzdtUbYGOlPRJUHLjY
                      yY4aXLkbgP6eyvJYHmLLNqmjJlxCAEqQahEJ0BEcIuJKmJ8w603DggXJ3QAjruZf
                      zfBMZ9fn915c6TeuKLvja6fyM5xHKXngHdnHJ5nuN0wvJnJKa5Y6Ju+M5SiVU2TR
                      v4ctVcoU9ZM7mBYeiq9goYsMtNqyJY+TgX2ysf0ryMogRvdYOdsSFbEOTYPtp2JM
                      3qo+Y8axO5AV3FEBr92U5KCKxhc82j4s2g9mtZDIO4iPFWYp8spOcCGtmRww8ErW
                      xQIDAQAB
                      -----END PUBLIC KEY-----
                      """
        else if /gts.archnet.mil:15677\/service\/topology\/get-routing-info*/.test options.url
          deferred.resolve
            routes: []
        else if /gts.archnet.mil:15677\/service\/fallbackRouting\/routeCreator/.test options.url
          deferred.resolve()
        else
          console.log "Nothing found for #{options.url}"
        return deferred.promise()

    stompSubscribeCallback = null
    stubbedStomp = ->
      heartbeat: {}
      connect: (username, password, succ, fail)-> succ()
      disconnect: (callback)->callback()
      subscribe: (destination, callback, headers)->
        stompSubscribeCallback = callback
        null
      send: (destination, headers, body)->
        iv = "F27D5C9927726BCEFE7510B1BDD3D137"
        salt = "3FF2EC019C627B945225DEBAD71A01B6985FE84C95A70EB132882F88C0A59A55"
        keySize = 256
        iterations = iterationCount = 1000
        passPhrase = "1qaz@WSX3e1qaz@WSX3e1qaz@WSX3e1qaz@WSX3e"

        message =
          data: "the aliens are located..."
        aesUtil = new AesUtil(keySize, iterationCount)
        cipherText = aesUtil.encrypt(salt, iv, passPhrase, JSON.stringify(message))
        plainText = aesUtil.decrypt(salt, iv, passPhrase, atob(cipherText))
        stompSubscribeCallback
          body: cipherText
          headers:
            SENDER_AUTH_TOKEN: JSON.stringify
              authenticationToken: "SgTy5WUsS5OQlb0KyF2lHw=="
              key:  """
                    jBy/WO59/B5gqSz2FeejxPtJYCswXC0y6/eO9JSLZfw5bQQonVqBt9mc80bFMGnj
                    F2zhS7WEKtNR42OaulgnWqsL+kKX05egt9MH7fo6AO6qUmyLmvIX+wry8r0waImU
                    gomdCWdKJIChAWhE36c2d2smHJYdyWbBg7+kDxWpx20hT10A047Ud/64IkWatfYm
                    h/r53+8FBoOP0k65pDeXQMUB1Swvn+tfJ1NXsgBtP3ag/tHaEyixAMcrfFGTs7Hm
                    j/bGEIv4ipzmOT3kyGnIiTf2B8f39aTMuvVwi4Lpjku7IDw96+FD+r+Kd4YxPMDR
                    bTTJLEfJy9yAqylyt/HVxw==
                    """
            "cmf.bus.message.correlation_id": "538bed6b-c05c-4e51-b284-68e8927346a8"
            "cmf.bus.message.id": "91b9f692-382d-4a7d-a186-0f5181c72606"
            "cmf.bus.message.sender_identity": "CN=dotnethater, OU=Users, OU=Capture, DC=archnet, DC=mil"
            "cmf.bus.message.topic": "GenericMessage"
            "cmf.bus.message.type": "GenericMessage"
            "cmf.bus.message.pattern": "cmf.bus.message.pattern#pub_sub"
            "content-length": "8785"
            "destination": ""
            "message-id": "T_sub-0@@session-VvPQxEyncEDZWOUzbBFyaQ@@1"
            "subscription": "sub-0"



    afterEach ->
      # $.ajax.restore()
      # Stomp.over.restore()
    beforeEach ->
      defaultMessagingKeystore = new DefaultMessagingKeystore()
      encryptedRequestHandler = new EncryptedRequestHandler()
      encryptedResponseHandler = new EncryptedResponseHandler()

    it 'should not be null', ->
      assert.notEqual null, encryptedRequestHandler
      assert.notEqual null, encryptedResponseHandler
      assert.notEqual null, defaultMessagingKeystore

    it 'should correctly prepare an encrypted message request', (done)->
      @timeout(5000)
      shortBus = ShortBus.getBus
        publishTopicOverride: "my.cool.topic.123"
        exchangeProviderHostname: "gts.archnet.mil"
        routingInfoHostname: "gts.archnet.mil"
        authenticationProviderHostname: "anubis.archnet.mil"
        fallbackTopoExchangeHostname: "rabbit.archnet.mil"
        messagingFactory: stubbedStomp

        busType: ShortBus.BUSTYPE.PUBSUB
      shortBus.subscribe({
        getEventType: ->
          return "GenericMessage"
        handle: (arg0, arg1)->
          assert.equal arg0.data, "the aliens are located..."
          done()
        handleFailed: (arg0, arg1)->
        }).then ->
          shortBus.publish("", "GenericMessage")
