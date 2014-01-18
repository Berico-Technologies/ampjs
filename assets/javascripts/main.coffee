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
    CryptoJSLib: 'vendor/managed/cryptojslib'
    CryptoJS: 'vendor/managed/cryptojslib/core'
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
    'CryptoJS':
      exports: 'CryptoJS'
    'Hashtable':
      exports: 'Hashtable'




requirejs [
  'amp/factory/ShortBus'
], (ShortBus) ->
