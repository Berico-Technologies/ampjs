define [
  '../../../bus/berico/EnvelopeHelper'
  '../../../util/Logger'
  'JSEncrypt'
  'amp/util/AesUtil'
  'amp/connection/topology/DefaultMessagingKeystore'
  'JSRSASIGN'
],
(EnvelopeHelper, Logger, JSEncrypt, AesUtil, DefaultMessagingKeystore, KEYUTIL)->
  class EncryptedResponseHandler

    constructor: (config={})->
      {@keystore, @authenticationProvider}=config

      unless _.isObject @keystore then @authenticationProvider = new DefaultMessagingKeystore()
      unless _.isObject @authenticationProvider then @authenticationProvider = new DefaultAuthenticationProvider()

    processInbound: (context)->

      #first build an envelope helper from the raw envelope received
      envelopeHelper = new EnvelopeHelper(context.getEnvelope())

      @authenticationProvider.getCredentials().then (data)->
        Logger.log.info "EncryptedResponseHandler.processInbound >>  message is pubsub, proceeding with decryption"

        # Extract SignedIdentityToken from headers
        signedIdentityToken = envelopeHelper.getSenderCredentials()

        # Use Anubis public key to verify token signature -- throw exception if invalid
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

        #grab identity token from msg
        signedIdentityToken = envelopeHelper.getSenderCredentials()

        #get signature from signed identity token
        signedIdentityTokenSignature = signedIdentityToken.signature

        #sign the identity token with the anubis public key
        sig = new KJUR.crypto.Signature({"alg": "SHA256withRSA", "prov": "cryptojs/jsrsa"});
        sig.initVerifyByCertificatePEM(anubisPublicKey)
        sig.updateString(signedIdentityToken.identityToken)

        #verify
        sig.verify(signedIdentityTokenSignature)

        # Locate encrypted key targeted to me
        encryptedKey = signedIdentityToken.keys[data.username]

        # Decrypt encrypted key -- if no key, no protection
        decryptor = new JSEncrypt()
        rsaKey = KEYUTIL.getRSAKeyFromPlainPKCS8PEM(
          "-----BEGIN PRIVATE KEY-----\n"+
          this.keystore.getPrivateKey(envelopeHelper.getReplyToTopic())+
          "\n-----END PRIVATE KEY-----")

        # Completely remove signature from envelope headers
        envelopeHelper.setDigitalSignature("")

        # Use decrypted key to verify signature


        #begin message decryption

        #then extract the authentication token
        anubisIdentity = envelopeHelper.getRsaEncryptedKeyHeader()

        #now use our private RSA key to decrypt the AES symmetric key from the identity token
        decryptor = new JSEncrypt()
        rsaKey = KEYUTIL.getRSAKeyFromPlainPKCS8PEM(
          "-----BEGIN PRIVATE KEY-----\n"+
          this.keystore.getPrivateKey(envelopeHelper.getReplyToTopic())+
          "\n-----END PRIVATE KEY-----")
        decryptor.setPrivateKey(KEYUTIL.getPEM(rsaKey, "PKCS1PRV"))
        passPhrase = decryptor.decrypt(anubisIdentity).replace(/(\r\n|\n|\r)/gm,"")

        if passPhrase == false
          Logger.log.info "EncryptedResponseHandler.processInbound >> failed to decrypt passphrase"

        else
          iv = envelopeHelper.getSymmetricKeyInitializationVector()
          salt = envelopeHelper.getSymetricKeySalt()
          keySize = envelopeHelper.getSymmetricKeySize()
          iterations = iterationCount = envelopeHelper.getSymmetricKeyIterationCount()

          aesUtil = new AesUtil(keySize, iterationCount)
          cipherText = envelopeHelper.getPayload()
          decrypted = aesUtil.decrypt(salt, iv, passPhrase, cipherText)
          if decrypted.length > 0
            Logger.log.info "EncryptedResponseHandler.processInbound >> successfully decrypted message"
            envelopeHelper.setPayload(decrypted)
            return true
          else
            Logger.log.info "EncryptedResponseHandler.processInbound >> failed to decrypt message"
            return false


    processOutbound: (context)->
      null