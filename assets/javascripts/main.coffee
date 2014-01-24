requirejs.config
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    i18n: 'vendor/managed/requirejs-i18n/i18n'
    domReady: 'vendor/managed/requirejs-domready/domReady'
    modernizr: 'vendor/managed/modernizr/modernizr'
    stomp: 'vendor/managed/stomp-websocket/stomp'
    underscore: 'vendor/managed/underscore-amd/underscore'
    sockjs: 'vendor/managed/sockjs/sockjs'
    flog: 'vendor/managed/flog/flog'
    uuid: 'vendor/managed/node-uuid/uuid'
    jquery: 'vendor/managed/jquery/jquery'
    LRUCache: 'vendor/managed/node-lru-cache/lru-cache'

    JSEncrypt: 'vendor/managed/jsencrypt/jsencrypt.min'
    CryptoJS_CipherCore: 'vendor/managed/cryptojslib/cipher-core'
    CryptoJS_AES: 'vendor/unmanaged/cryptojslib/aes'
    CryptoJS_PBKDF2: 'vendor/unmanaged/cryptojslib/pbkdf2'
    CryptoJS_HMAC: 'vendor/unmanaged/cryptojslib/hmac'
    CryptoJS_SHA1: 'vendor/unmanaged/cryptojslib/sha1'
    CryptoJS_SHA384: 'vendor/unmanaged/cryptojslib/sha384'
    CryptoJS_SHA512: 'vendor/unmanaged/cryptojslib/sha512'
    CryptoJS_ENC_BASE64: 'vendor/unmanaged/cryptojslib/enc-base64'
    CryptoJS_Core: 'vendor/unmanaged/cryptojslib/core'
    CryptoJS_x64Core: 'vendor/unmanaged/cryptojslib/x64-core'

    Hashtable : 'vendor/managed/jshashtable/hashtable'
  shim:
    'modernizr':
      exports: 'Modernizr'
    'stomp':
      exports: 'Stomp'
    'sockjs':
      exports: 'SockJS'
    'uuid':
      exports: 'uuid'
    'jquery':
      exports: 'jquery'
    'LRUCache':
      exports: 'LRUCache'

    'JSEncrypt':
      exports: "JSEncrypt"
    'CryptoJS_CipherCore':
      deps: ['CryptoJS_Core']
    "CryptoJS_AES":
      deps: ['CryptoJS_Core','CryptoJS_CipherCore']
    'CryptoJS_PBKDF2':
      deps: ['CryptoJS_Core', 'CryptoJS_HMAC', 'CryptoJS_SHA384']
    'CryptoJS_HMAC':
      deps: ['CryptoJS_Core']
    'CryptoJS_SHA384':
      deps: ['CryptoJS_Core', 'CryptoJS_x64Core', 'CryptoJS_SHA512']
    'CryptoJS_x64Core':
      deps: ['CryptoJS_Core']
    'CryptoJS_SHA512':
      deps: ['CryptoJS_Core', 'CryptoJS_x64Core']
    'CryptoJS_ENC_BASE64':
      deps: ['CryptoJS_Core']
    'Hashtable':
      exports: 'Hashtable'





requirejs [
  'amp/factory/ShortBus'
], (ShortBus) ->
