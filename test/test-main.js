var tests = Object.keys(window.__karma__.files).filter(function (file) {            
      return /Spec\.coffee-compiled\.js$/.test(file);
});
requirejs.config({
    // Karma serves files from '/base'
    baseUrl: '/base/public/javascripts',

    paths: {
        'i18n': 'vendor/managed/requirejs-i18n/i18n',
        'domReady': 'vendor/managed/requirejs-domready/domReady',
        'underscore': 'vendor/managed/underscore-amd/underscore',
        'stomp': 'vendor/managed/stomp-websocket/dist/stomp',
        'test':'../../test'
    },

    shim: {
        'stomp': {
            exports: 'Stomp'
        }
    },

    // ask Require.js to load these files (all our tests)
    deps: tests,

    // start test run, once Require.js is done
    callback: window.__karma__.start
});