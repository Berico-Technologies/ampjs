var tests = Object.keys(window.__karma__.files).filter(function(file){
  // return /Spec\.coffee-compiled\.js$/.test(file);
  // return /(envelope|eventBus|globalTopology|simpleTopology|webStompChannel|webStompTransport).*\.coffee-compiled\.js$/.test(file);
  return /(shortBus).*\.coffee-compiled\.js$/.test(file);
});

testConfig = {
  useEmulatedWebSocket: false,
  useSimulatedManager: false,
  configureLoggingLevel: function(){
    window.loggingLevel = 'all';
  }()
};

//configure mocha to ignore the global variable jquery throws jsonp responses into
mocha.setup({
  globals: [ 'jQuery*' ]
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
    'jquery': 'vendor/managed/jquery/jquery',
    'LRUCache': 'vendor/managed/node-lru-cache/lib/lru-cache'
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
    }
  },
  deps: tests,
  callback: window.__karma__.start
});

