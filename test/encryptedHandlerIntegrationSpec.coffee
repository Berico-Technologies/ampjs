# IGNORED; remove the 'x' from 'xit'
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
    # unless testConfig.useEmulatedWebSocket || testConfig.useSimulatedManager
      it 'should correctly prepare an encrypted message request', (done)->
        anubisPublicKey = """
          -----BEGIN CERTIFICATE-----
          MIIGUTCCBDmgAwIBAgIKEKTpZQABAAAH2jANBgkqhkiG9w0BAQUFADBNMRMwEQYK
          CZImiZPyLGQBGRYDY29tMRgwFgYKCZImiZPyLGQBGRYIam9obnJ1aXoxHDAaBgNV
          BAMTE2pvaG5ydWl6LUlTU1VFMDEtQ0EwHhcNMTMwNzE2MjM1MDAxWhcNMTQwNDEw
          MDEzOTA4WjAeMRwwGgYDVQQDExNhbnViaXMuam9obnJ1aXouY29tMIIBIjANBgkq
          hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArik4i6hH5YTx/hFI9hSBgGP4NQu29FVD
          KFDwH/JlLu3RBTc3U26D8ytKaLpELsQ0rpkjkIOWfx6hm+qsgifzoNw2oQG/yJYR
          t0nfsY9oStx68lSbe5XxZe4EopL1TG2aVYs2+s7zyGgXcmTGe346NCWwtZpgNvT1
          86HyqPAZT/Uz9PoC2vUo2uQGQAYgeXzIU9shipJ1+O4CdBOxLGlkWkTz3R+VOM3b
          IF2fSFcU0EQPyDi+kF0/l/B4fuitUjAGxqblGatQ9UX4FvBBssHMqj/HIXM0JdY1
          xUkBWoDwXL+m0eDSvroZOO4AkcB/znLigyStMM7o4j4IJ5lzYaBzDQIDAQABo4IC
          YDCCAlwwHQYDVR0OBBYEFGfOtaTOhMUJ1DqB8XmRr+ggpEFBMB8GA1UdIwQYMBaA
          FLKQWmVEFeFNb/u/E852AXGp5cOTMIHWBgNVHR8Egc4wgcswgciggcWggcKGgb9s
          ZGFwOi8vL0NOPWpvaG5ydWl6LUlTU1VFMDEtQ0EsQ049cGtpLWlzc3VlMDEsQ049
          Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv
          bmZpZ3VyYXRpb24sREM9am9obnJ1aXosREM9Y29tP2NlcnRpZmljYXRlUmV2b2Nh
          dGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludDCB
          +AYIKwYBBQUHAQEEgeswgegwgbMGCCsGAQUFBzAChoGmbGRhcDovLy9DTj1qb2hu
          cnVpei1JU1NVRTAxLUNBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
          cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWpvaG5ydWl6LERDPWNv
          bT9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1
          dGhvcml0eTAwBggrBgEFBQcwAYYkaHR0cDovL3BraS1pc3N1ZTAxLmpvaG5ydWl6
          LmNvbS9vY3NwMCEGCSsGAQQBgjcUAgQUHhIAVwBlAGIAUwBlAHIAdgBlAHIwDgYD
          VR0PAQH/BAQDAgWgMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA0GCSqGSIb3DQEBBQUA
          A4ICAQBJTM0m+f3CHtHx1tBIzr6JeuR92tT3/9jOsyVqa9c6Tn0LLnzbPoFXwwCd
          6rQYdN5+yHZgYLV/WtiqzYiZ1TaqL3HIebxaTw2yLF/u1SLBM5nI8lHC+DY7U03J
          K69b2CmvbLc40SXEt+BHEV+J1zOM3eRxXhL7Fhi5g+87EZmT+JD3x/vGPwqX12pF
          ErpqkSwGQmk9CfVfFrBl1STtlb7u1eESiqBGuhpxq+GoAoS/BzP+jMhZIx/EyEyT
          d4BchoeQeOiQrfPIH1Znp1d4b0X69//LSjGgaLLL5dgrF1ZYnj8ARbx4FgSEeScT
          FYvzj11XqnApqd2o+PwR914OZb6UOGMeo5otUVUmLNeaEBqluVAFy2yzQbTLa96n
          qFx9xQ5Dx4fM2uWL6le+hfqzE5XEXhag5lPd9jEnHJNuHszGZiaF6K2nkOui3n58
          XM1wwsuRI01r8Zw2+3TLP0R9KlhPSVl9lJqUkw84xRhDQTRoXyQGRJlztJ8BMjSt
          AuVlJuVf69ENPaO0nnseJ7D5F5UrNmq41pdu1HmLvnjgi6IbyvdeDYqCttXyQEIQ
          WIDrtlckdxSikZQbqiGc+G0OR8E4KkO5Y7g6yAUFgQurGAiFThPO6UIgf2UbxEu2
          5zf7sfAcoOr8Tf7fl6MIUdP4uOmtciovBIa3aic55CvG9Y8nnw==
          -----END CERTIFICATE-----
        """
        c = new X509()
        c.readCertPEM(anubisPublicKey)


        @timeout(100000)
        shortBus = ShortBus.getBus
          exchangeProviderHostname: "gts.johnruiz.com"
          exchangeProviderPort: 15677
          routingInfoHostname: "gts.johnruiz.com"
          routingInfoPort: 15677
          authenticationProviderHostname: "anubis.johnruiz.com"
          authenticationProviderPort: 15678
          fallbackTopoExchangeHostname: "rabbit01.johnruiz.com"
          fallbackTopoExchangePort: 15679
          useEncryption: true
          busType: 'event'
        shortBus.subscribe({
          getEventType: ->
            return "mil.capture.cmf.drivers.TestEncryptedResponse"
          handle: (arg0, arg1)->
            console.log arg0.message
            assert.equal arg0.message, "This is my rifle. There are many like it, but this one is mine.My rifle is my best friend. It is my life. I must master it as I must master my life.My rifle, without me, is useless. Without my rifle, I am useless. I must fire my rifle true. I must shoot straighter than my enemy who is trying to kill me. I must shoot him before he shoots me. I will...My rifle and I know that what counts in this war is not the rounds we fire, the noise of our burst, nor the smoke we make. We know that it is the hits that count. We will hit...My rifle is human, even as I, because it is my life. Thus, I will learn it as a brother. I will learn its weaknesses, its strength, its parts, its accessories, its sights and its barrel. I will keep my rifle clean and ready, even as I am clean and ready. We will become part of each other. We will...Before God, I swear this creed. My rifle and I are the defenders of my country. We are the masters of our enemy. We are the saviors of my life.So be it, until victory is America's and there is no enemy."
            done()
          handleFailed: (arg0, arg1)->
          }).then ->
            shortBus.publish({'body':'interesting stuff...'}, 'mil.capture.cmf.drivers.TestEncryptedRequest')
