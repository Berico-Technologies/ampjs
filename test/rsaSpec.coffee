define [
  'JSEncrypt'
],
(JSEncrypt) ->
  describe 'RSA decryption', ->
    it 'should work on java data', ->
      privateKey = """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEA5uhOfQsjbe9Xe5CiWSFELy3nDJiKODFdmpWgp7OV7+N2GlHX
        aYSs5/olWuTdUKQ0uzj8aixHNiu8d3JUDerShSDSlGpbwE0pmB5ufJS1B6BYlhnk
        GZ07Cw8yEHn1W/ORRKN1zMSaGEx3XiABW9n4yq1CvyIQuwbY/RvkIYxW/e+zH7+Y
        7D3j96FoUyMq6Z+PKpLLf6vPKSPQ5wXGhC4Im3pgucIxry0zmCcQw7nJMwOTsRcQ
        sZobjCLw/xbii6mZcjamAZvAvf/D+PTRhKLxJD9mtaVbIxCWzrW3F1SXAMlDFygn
        C93nfJ4OnxQpodWsErYDvcvaDzgcNAyPjJCvSQIDAQABAoIBACkXqHgqVkjHMktk
        JvAzsl2vDpI4R0jOyDitbiTKGeHSGf9/FxXJLbgu1R0C47vpLRUwhAMlFBs411Zu
        ezTq2EIm4DLXZrKnSMKwj7sN/9V2nK1BuE0ypQJH1wIFojuV8gFEEb+6MS4n1Ypj
        qbo95T+0a8918YJHKrCImSW7QvP3sNEpu3AvT2TINc5vADavArhbpiyrIBcURblw
        E42H29Fud/hTk/W9SVBb1YQ4TyUZSCo4RXSp5w/S3PGT1Tz7EX4gjXqYdhJJZQip
        G3YWB7MLrfjDBfppUgMx/is+xUbRSxNLRgvJkrBQwGBVO//W37AtjCLppO9UqIjq
        FSoYPgECgYEA/GEYfax4HYWm2HvYBsRWt82jjeO3tO09/FqDUBXbU1pQFgTZPqBS
        dezV7DiOqJQyn8p8KfFDw3pnqLwEyV8iMnziHhYrFsRleJs8plb/L1wuKqj7MvRe
        HpwUV0bebPtw9zA/SeHNCKAVs/lqiy6WLjuoSvks3jFzeAeO1SwSGQkCgYEA6jha
        Iyy/ZaUQhUp9dTDpuV8fFFYwzIFh+3589BR5RB6AEAobXJuAyiT7MLPd/OvOfRNl
        HBGWYKK7ufO6K/HwM63tONp5aENSW6bPGn4CRv4v5eMR605i05XSOfe7JAmicfMx
        nrGobFSAFfboO/tiGEFlHmhC4tJ5Ej0/R3zutEECgYBEpZxlwp3BWfMx+y2dWZZE
        1HhiRchYPBeaJnyFMgzANVaHRrZYpH8JeGwPnqqfDABhGlB/kBJgf1Dmwo2CwI+q
        r/FJQbpirPT0wzTSAePTW/1quR/qkjFvngCiZLJnblUhx0vPqs18RR7iHztttDRB
        SxTRn8kmfsjroxKkxSH/EQKBgF8B7M5H4HuCsWjgBnP7G1OuWhUNwU2zTeOOM3Fu
        vKH9HUVkVCUEjwFwbtQaofluTZw+uczg9XbNjAip7OLWiPDtpERjmsvIQygaSfgd
        FR9nDFbb/PDOIxhgtZ3991Nu9Q3z8DTHK+KFhE9kkF+EYQ4luLbU5AzOA356iaid
        7NYBAoGBAMkxq7me0dqDP77x/11geOl5uUbY1mLPpyihRBtXZY2rtT2ii9SoBWS2
        nip0UlZmnKUgSYrhaKt1dW+BcVqjS5nKF18KIn/d8CFC8oG9Ha/z0qo90r0Okn5q
        5KSIU0WrjGcIr4/g0QasKZdMkGuJuYEuO+KbA8fsam8rFfHj7Xb2
        -----END RSA PRIVATE KEY-----
      """
      base64Data = """
        UiJr51sS0uVZXLZ2IFglilrRfVSB6CJODorNvLtp8D1YflAI/YTqoSg9SwqiBSfO3dusOsjGnSQAyY8En4u0z+sGbhkLylVfSwxPHIv+ODmiGPsUcrao6XpysvLA4gK6bzNOVBv8YRoJq83UJNy6VLtx5eD+EFtRmTcSVmAIbkJ7iyVYgmLIDlzsYosSc0nIxymoMa5/XQRVKFA8h04/nFGj4dRZH3i9Quw+WvuZgz9fgbgohzOVjAjvO98VLAB0UMbYqZcnmABFt1JQaFaWynSwAOssxg/MAgkrhLNyzW/khT9gMzHsBxOWKgO1a2j5RYu28oVD2OeoQ/brtsI7Uw==
      """
      binaryData = atob(base64Data)
      decryptor = new JSEncrypt()
      decryptor.setPrivateKey privateKey
      decryptedData = decryptor.decrypt(binaryData)

      console.log decryptedData