exports.config =
  minMimosaVersion:"1.0.1"
  modules: [
    'require'
    'minify'
    'bower'
    'require-lint'
    'mimosa-jshint'
    'require-library-package'
    'mimosa-karma-enterprise'
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
    name:"ShortBus.min.js"
    main:"amp/factory/ShortBus"
    mainConfigFile: "javascripts/main.js"
    removeDependencies: []
