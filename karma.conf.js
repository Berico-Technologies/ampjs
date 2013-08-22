module.exports = function(config){
  config.set({

    frameworks: [
      'mocha',
      'requirejs'
    ],

    // list of files / patterns to load in the browser
    files : [
      'test/vendor/assert.js',
      'test/vendor/sinon-1.7.1.js',
      'test/test-main.js',
      {pattern: 'test/*Spec.coffee', included: false},
      {pattern: 'public/javascripts/**/*.js', included: false},
      {pattern: 'test/websocket/*.coffee', included: false}
    ],

    // list of files to exclude
    exclude : [
      'public/javascripts/main.js'
    ],

    // test results reporter to use
    reporters : ['dots', 'junit', 'coverage'],

    junitReporter : {
      outputFile: 'test-results.xml'
    },

    // web server port
    port : 9876,

    // enable / disable colors in the output (reporters and logs)
    colors : true,

    // level of logging
    logLevel : config.LOG_INFO,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch : false,

    // Start these browsers, currently available:
    browsers : ['PhantomJS'],

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout : 60000,

    // if true, it capture browsers, run tests and exit
    singleRun : true,

    // report which specs are slower than 500ms
    reportSlowerThan: 500,

    preprocessors : {
      '**/*.coffee' : 'coffee',
      'public/javascripts/amp/**/*.js' : ['coverage']
    },

    coverageReporter : {
      type: 'cobertura',
      dir: 'coverage/',
      file: 'coverage.xml'
    },

    // cli runner port
    runnerPort : 9100

  });
};