requirejs.config
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    i18n: 'vendor/managed/requirejs-i18n/i18n'
    domReady: 'vendor/managed/requirejs-domready/domReady'
    modernizr: 'vendor/managed/modernizr/modernizr'
  shim:
    'modernizr':
      exports: 'Modernizr'


#Begin loading the application.
#Also wire routes here since providers aren't available once the injector is created
requirejs [

], () ->

