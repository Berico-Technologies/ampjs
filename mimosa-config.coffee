exports.config =
  minMimosaVersion:"1.0.1"
  modules: ['lint'
    'server'
    'require'
    'minify'
    'live-reload'
    'bower'
    'require-lint']
  server:
    defaultServer:
      enabled: true
    views:
      compileWith: 'html'
      extension: 'html'
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