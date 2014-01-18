var tests = Object.keys(window.__karma__.files).filter(function(file){
  return /(encryptedHandlerSpec|envelopeSpec|webStompTransportProviderSpec|webStompChannelProviderSpec|simpleTopologyServiceSpec)\.js$/.test(file);
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
    'JSEncrypt': 'vendor/managed/jsencrypt/jsencrypt.min',
    'CryptoJSLib': 'vendor/managed/cryptojslib',
    'CryptoJS' : 'vendor/managed/cryptojslib/core',
    'Hashtable' : 'vendor/managed/jshashtable/hashtable'
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
    'JSEncrypt':{
      exports: "JSEncrypt"
    },
    'CryptoJSLib/cipher-core':{
      deps: ['CryptoJSLib/core']
    },
    "CryptoJSLib/aes":{
      deps: ['CryptoJSLib/core','CryptoJSLib/cipher-core']
    },
    'CryptoJSLib/pbkdf2':{
      deps: ['CryptoJSLib/core', 'CryptoJSLib/hmac', 'CryptoJSLib/sha384']
    },
    'CryptoJSLib/hmac':{
      deps: ['CryptoJSLib/core']
    },
    'CryptoJSLib/sha384':{
      deps: ['CryptoJSLib/core', 'CryptoJSLib/x64-core', 'CryptoJSLib/sha512']
    },
    'CryptoJSLib/x64-core':{
      deps: ['CryptoJSLib/core']
    },
    'CryptoJSLib/sha512':{
      deps: ['CryptoJSLib/core', 'CryptoJSLib/x64-core']
    },
    'CryptoJSLib/enc-base64':{
      deps: ['CryptoJSLib/core']
    },
    'Hashtable':{
      exports: 'Hashtable'
    }
  },
  deps: tests,
  callback: window.__karma__.start
});

