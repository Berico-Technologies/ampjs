var tests = Object.keys(window.__karma__.files).filter(function(file){
  return /(Spec)\.js$/.test(file);
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
    CryptoJS_CipherCore: 'vendor/managed/cryptojslib/cipher-core',
    CryptoJS_AES: 'vendor/unmanaged/cryptojslib/aes',
    CryptoJS_PBKDF2: 'vendor/unmanaged/cryptojslib/pbkdf2',
    CryptoJS_HMAC: 'vendor/unmanaged/cryptojslib/hmac',
    CryptoJS_SHA1: 'vendor/unmanaged/cryptojslib/sha1',
    CryptoJS_SHA384: 'vendor/unmanaged/cryptojslib/sha384',
    CryptoJS_SHA512: 'vendor/unmanaged/cryptojslib/sha512',
    CryptoJS_ENC_BASE64: 'vendor/unmanaged/cryptojslib/enc-base64',
    CryptoJS_Core: 'vendor/unmanaged/cryptojslib/core',
    CryptoJS_x64Core: 'vendor/unmanaged/cryptojslib/x64-core',

    Hashtable : 'vendor/managed/jshashtable/hashtable'
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
   'JSEncrypt': {
      exports: "JSEncrypt"
    },
    'CryptoJS_CipherCore': {
      deps: ['CryptoJS_Core']
    },
    "CryptoJS_AES": {
      deps: ['CryptoJS_Core', 'CryptoJS_CipherCore']
    },
    'CryptoJS_PBKDF2': {
      deps: ['CryptoJS_Core', 'CryptoJS_HMAC', 'CryptoJS_SHA384', 'CryptoJS_SHA1']
    },
    'CryptoJS_HMAC': {
      deps: ['CryptoJS_Core']
    },
    'CryptoJS_SHA384': {
      deps: ['CryptoJS_Core', 'CryptoJS_x64Core', 'CryptoJS_SHA512']
    },
    'CryptoJS_x64Core': {
      deps: ['CryptoJS_Core']
    },
    'CryptoJS_SHA512': {
      deps: ['CryptoJS_Core', 'CryptoJS_x64Core']
    },
    'CryptoJS_SHA1': {
      deps: ['CryptoJS_Core']
    },
    'CryptoJS_ENC_BASE64': {
      deps: ['CryptoJS_Core']
    },
    'Hashtable':{
      exports: 'Hashtable'
    }
  },
  deps: tests,
  callback: window.__karma__.start
});

