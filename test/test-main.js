var tests = Object.keys(window.__karma__.files).filter(function(file){
  // return /Spec\.coffee-compiled\.js$/.test(file);
  return /webStompTransportProviderSpec\.coffee-compiled\.js/.test(file);
});

requirejs.config({
  baseUrl: '/base/public/javascripts',
  paths:{
    'i18n': 'vendor/managed/requirejs-i18n/i18n',
    'domReady': 'vendor/managed/requirejs-domready/domReady',
    'underscore': 'vendor/managed/underscore-amd/underscore',
    'stomp': 'vendor/managed/stomp-websocket/dist/stomp',
    'flog': 'vendor/managed/flog/flog',
    'uuid': 'vendor/managed/node-uuid/uuid',
    'test': '../../test',
    'sockjs': 'vendor/managed/sockjs/sockjs',
    'jshashes': 'vendor/managed/jsHashes/hashes',
    'jquery': 'vendor/managed/jquery/jquery'
  },
  shim:{
    'stomp':{
      exports: 'Stomp'
    },
    'uuid':{
      exports: 'uuid'
    },
    'sockjs':{
      exports: 'SockJS'
    },
    'jquery':{
      exports: 'jquery'
    }
  },
  deps: tests,
  callback: window.__karma__.start
});

