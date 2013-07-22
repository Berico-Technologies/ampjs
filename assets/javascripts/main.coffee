requirejs.config
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    i18n: 'vendor/managed/requirejs-i18n/i18n'
    domReady: 'vendor/managed/requirejs-domready/domReady'
    modernizr: 'vendor/managed/modernizr/modernizr'
    stomp: 'vendor/managed/stomp-websocket/dist/stomp'
    underscore: 'vendor/managed/underscore-amd/underscore'
    sockjs: 'vendor/managed/sockjs/sockjs'
    flog: 'vendor/managed/flog/flog'
    uuid: 'vendor/managed/node-uuid/uuid'
    jshashes: 'vendor/managed/jshashes/hashes'
    jquery: 'vendor/managed/jquery/jquery'
    LRUCache: 'vendor/managed/node-lru-cache/lib/lru-cache'
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


requirejs [
  'amp/factory/ShortBus'
], (ShortBus) ->
