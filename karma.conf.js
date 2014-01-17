module.exports = function(config){
  config.set({

    frameworks: [ 'mocha', 'requirejs'],
    files : [
      'test/vendor/assert.js',
      'test/vendor/sinon-1.7.1.js',
      'test/test-main.js',
      {pattern: 'test/*Spec.coffee', included: false},
      {pattern: 'assets/javascripts/**/*.js', included: false},
      {pattern: 'assets/javascripts/**/*.coffee', included: false},
      {pattern: 'test/websocket/*.coffee', included: false}
    ],

    exclude : ['assets/javascripts/main.js'],
    reporters : ['dots', 'junit', 'coverage'],
    junitReporter : {outputFile: 'test-results.xml'},
    colors : true,
    autoWatch : false,
    singleRun : true,
    runnerPort : 9100,
    port : 9876,
    reportSlowerThan: 500,
    browsers : ['PhantomJS'],
    preprocessors : {
      // 'assets/javascripts/**/*.coffee' : 'coverage',
      'assets/**/*.coffee': 'coffee',
      'test/**/*.coffee': 'coffee'
    },
    coffeePreprocessor: {
      options: {
        sourceMap: true,
        bare: true
      }
    },
    coverageReporter : {
      type: 'cobertura',
      dir: 'coverage/',
      file: 'coverage.xml'
    },

    logLevel : config.LOG_ERROR

  });
};