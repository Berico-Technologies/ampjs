exports.config =
  minMimosaVersion:"2.1.0"

  modules: [
    "minify-js"
    "minify-css"
    "csslint"
    "require"
    "bower"
    "copy"
    "coffeescript"
    "jshint"
    "karma-enterprise"
    "require-library-package"
    "require-lint"
    "stylus"
  ]

  karma:
    configFile: 'karma.conf.js'
    externalConfig: true

  bower:
    bowerDir:
      clean:false
    copy:
      outRoot: "managed"
      mainOverrides:
        modernizr:["modernizr.js"]
        "stomp-websocket":["dist/stomp.js"]
        "requirejs-domready":["domReady.js"]
        "requirejs-i18n":["i18n.js"]
        "jsrsasign":["jsrsasign-latest-all-min.js"]

  libraryPackage:
    packaging:
      shimmedWithDependencies:true
      noShimNoDependencies:true
      noShimWithDependencies:true
    overrides:
      shimmedWithDependencies: {}
      noShimNoDependencies: {}
      noShimWithDependencies: {}
    outFolder: "build"
    cleanOutFolder: true
    globalName: "ShortBus"
    name: "ShortBus.min.js"
    main: "amp/factory/ShortBus"
    mainConfigFile: "javascripts/main.js"
    removeDependencies: []
