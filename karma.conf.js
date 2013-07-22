// list of files / patterns to load in the browser
files = [
  MOCHA,
  MOCHA_ADAPTER,
  REQUIRE,
  REQUIRE_ADAPTER,
  'test/vendor/assert.js',
  'test/vendor/sinon-1.7.1.js',
  'test/test-main.js',
  {pattern: 'test/*Spec.coffee', included: false},
  {pattern: 'public/javascripts/**/*.js', included: false},
  {pattern: 'test/websocket/*.coffee', included: false}
];

preprocessors = {
  '**/*.coffee' : 'coffee'
};

// list of files to exclude
exclude = [
  'public/javascripts/main.js'
];


// test results reporter to use
// possible values: 'dots', 'progress', 'junit'
reporters = ['dots', 'junit', 'coverage'];

junitReporter = {
  outputFile: 'test-results.xml'
};

preprocessors['public/javascripts/amp/**/*.js'] = 'coverage';

coverageReporter={
  type: 'cobertura',
  dir: 'coverage/',
  file: 'coverage.xml'
};


// web server port
port = 9876;


// cli runner port
runnerPort = 9100;


// enable / disable colors in the output (reporters and logs)
colors = true;


// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_ERROR;


// enable / disable watching file and executing tests whenever any file changes
autoWatch = false;


// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari (only Mac)
// - PhantomJS
// - IE (only Windows)
browsers = ['PhantomJS'];


// If browser does not capture in given timeout [ms], kill it
captureTimeout = 60000;


// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = true;
