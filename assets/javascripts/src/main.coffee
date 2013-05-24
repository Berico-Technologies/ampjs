requirejs.config
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    i18n: 'vendor/managed/requirejs-i18n/i18n'
    domReady: 'vendor/managed/requirejs-domready/domReady'
    modernizr: 'vendor/managed/modernizr/modernizr'
    stomp: 'vendor/managed/stomp-websocket/dist/stomp',
    underscore: 'vendor/managed/underscore-amd/underscore',
    sockjs: 'vendor/managed/sockjs/sockjs'
  shim:
    'modernizr':
      exports: 'Modernizr'
    'stomp':
      exports: 'Stomp'
    'sockjs':
      exports: 'SockJS'

requirejs [
  'underscore'
  'stomp'
  'sockjs'
], (_,Stop, SockJS) ->
