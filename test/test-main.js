var tests = Object.keys(window.__karma__.files).filter(function(file){
  return /(encryptedHandlerIntegrationSpec)\.js$/.test(file);
  // return /(encryptedHandlerSpec)\.js$/.test(file);
  // return /encryptionBenchmarkSpec\.js$/.test(file);
  // return /(envelope|eventBus|globalTopology|simpleTopology|webStompChannel|webStompTransport).*\.coffee-compiled\.js$/.test(file);
  // return /(simpleTopology).*\.js$/.test(file);
});

testConfig = {
  useEmulatedWebSocket: true,
  useSimulatedManager: true,
  configureLoggingLevel: function(){
    window.loggingLevel = 'all';
  }()
};

//configure mocha to ignore the global variable jquery throws jsonp responses into
mocha.setup({
  globals: [ 'jQuery*' ]
});

requirejs.config({
  baseUrl: '/base/assets/javascripts',
  paths:{
    'i18n': 'vendor/managed/requirejs-i18n/i18n',
    'domReady': 'vendor/managed/requirejs-domready/domReady',
    'underscore': 'vendor/managed/underscore-amd/underscore',
    'stomp': 'vendor/managed/stomp-websocket/stomp',
    'flog': 'vendor/managed/flog/flog',
    'uuid': 'vendor/managed/node-uuid/uuid',
    'test': '../../test',
    'sockjs': 'vendor/managed/sockjs/sockjs',
    'jquery': 'vendor/managed/jquery/jquery',
    'LRUCache': 'vendor/managed/node-lru-cache/lru-cache',

    JSEncrypt: 'vendor/managed/jsencrypt/jsencrypt.min',
    Hashtable : 'vendor/managed/jshashtable/hashtable',
    JSRSASIGN: 'vendor/managed/jsrsasign/jsrsasign-latest-all-min'

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
    },
    'LRUCache':{
      exports: 'LRUCache'
    },
    'JSRSASIGN':{
      exports: 'KEYUTIL'
    },
   'JSEncrypt': {
      exports: "JSEncrypt"
    },

    'Hashtable':{
      exports: 'Hashtable'
    }
  },
  deps: tests,
  callback: window.__karma__.start
});

