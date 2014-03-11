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
    "lint"
    "minify"
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

  require:
    optimize:
      overrides: (cfg) ->
        cfg.optimize = "none"
        console.log cfg
        cfg

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

###[
      "i18n",
      "domReady",
      "modernizr",
      "stomp",
      "underscore",
      "sockjs",
      "flog",
      "uuid",
      "jquery",
      "LRUCache",
      "JSEncrypt",
      "CryptoJS_CipherCore",
      "CryptoJS_AES",
      "CryptoJS_PBKDF2",
      "CryptoJS_HMAC",
      "CryptoJS_SHA384",
      "CryptoJS_SHA512",
      "CryptoJS_ENC_BASE64",
      "CryptoJS_Core",
      "CryptoJS_x64Core",
      "Hashtable"
    ] ###
