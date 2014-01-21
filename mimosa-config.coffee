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
        "cryptojslib":[
          "components/aes.js"
          "components/cipher-core.js"
          "components/core.js"
          "components/enc-base64.js"
          "components/enc-utf16.js"
          "components/evpkdf.js"
          "components/format-hex.js"
          "components/hmac.js"
          "components/lib-typedarrays.js"
          "components/md5.js"
          "components/mode-cfb.js"
          "components/mode-ctr-gladman.js"
          "components/mode-ctr.js"
          "components/mode-ecb.js"
          "components/mode-ofb.js"
          "components/pad-ansix923.js"
          "components/pad-iso10126.js"
          "components/pad-iso97971.js"
          "components/pad-nopadding.js"
          "components/pad-zeropadding.js"
          "components/pbkdf2.js"
          "components/rabbit-legacy.js"
          "components/rabbit.js"
          "components/rc4.js"
          "components/ripemd160.js"
          "components/sha1.js"
          "components/sha224.js"
          "components/sha256.js"
          "components/sha3.js"
          "components/sha384.js"
          "components/sha512.js"
          "components/tripledes.js"
          "components/x64-core.js"
        ]
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
    removeDependencies: [
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
    ]
