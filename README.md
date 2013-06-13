AMPJS
=====
A Javascript WEB-STOMP-based client for [AMP](https://github.com/Berico-Technologies/AMP)

Usage
-------------
To use the AmpJS client you need to both install it into your project and then configure it for your STOMP broker.
###Installation###
This project is packaged as a [BOWER](https://github.com/bower/bower) module but is not listed in the bower repo. To install a particular version (in this case version 0.0.5) of this project through bower you will need run a command like this:
    bower install https://github.com/Berico-Technologies/ampjs.git#0.0.5

The package is written as a [RequireJS](http://requirejs.org/) module and has a number of dependencies on other supporting libraries. All required dependencies should be brought into the project as part of the initial bower install, however you will need to define the installed libraries with appropriate keys for AmpJS to find them:

    paths:{

        i18n: 'vendor/managed/requirejs-i18n/i18n',
        domReady: 'vendor/managed/requirejs-domready/domReady',
        modernizr: 'vendor/managed/modernizr/modernizr',
        stomp: 'vendor/managed/stomp-websocket/dist/stomp',
        underscore: 'vendor/managed/underscore-amd/underscore',
        sockjs: 'vendor/managed/sockjs/sockjs',
        flog: 'vendor/managed/flog/flog',
        uuid: 'vendor/managed/node-uuid/uuid',
        jshashes: 'vendor/managed/jsHashes/hashes',
        jquery: 'vendor/managed/jquery/jquery'
    },
    shim:{
        'modernizr':{
            exports: 'Modernizr'
        },
        'stomp':{
            exports: 'Stomp'
        },
        'sockjs':{
            exports: 'SockJS'
        },
        'uuid':{
            exports: 'uuid'
        },
        'jquery':{
            exports: 'jquery'
        }
    }

###Configuration###
Assuming you have installed and aliased AmpJS to 'cmf,' here is how you would instantiate the client and publish / subscribe to a topic. **Note that in this example messages are not published on the topic until the subscriber's deferred is resolved. Any messages published on the topic before the subscriber is initialized will not be received by the client**

    requirejs([
      'cmf/bus/berico/TransportProviderFactory',
      'cmf/eventing/berico/serializers/JsonEventSerializer',
      'cmf/eventing/berico/EventBus',
      'cmf/bus/berico/EnvelopeBus',
      'cmf/eventing/berico/OutboundHeadersProcessor',
      'cmf/webstomp/ChannelProvider'
    ], function(TransportProviderFactory, JsonEventSerializer, EventBus, EnvelopeBus, OutboundHeadersProcessor, ChannelProvider,$){
      GenericMessage = (function() {
        function GenericMessage(name, type, visualization) {
          this.name = name;
          this.type = type;
          this.visualization = visualization;
        }

        return GenericMessage;

      })();

      var payload = new GenericMessage("Laughing Out Loud", "emoticon", "lol");

      var transportProvider = TransportProviderFactory.getTransportProvider(
        TransportProviderFactory.TransportProviders.WebStomp
      });

      var eventBus = new EventBus(
        new EnvelopeBus(transportProvider),
        [new JsonEventSerializer()],
        [new OutboundHeadersProcessor(), new JsonEventSerializer()]
      );
      eventBus.subscribe({
        getEventType: function() {
          return "GenericMessage";
        },
        handle: function(arg0, arg1) {
          //do something with the event here
        },
        handleFailed: function(arg0, arg1) {}
      }).then(function() {
        return eventBus.publish(payload);
      });
    })



Running Tests
-------------
1. Compile the source code. We're using mimosa, so either have the project running 'mimosa watch -s' or compile the code 'mimosa build'

2. Once the code is compiled you should be able to run the unit tests 'karma start'

    **NOTE: the project does not currently include phantomjs. **You need to download it yourself and set the PHANTOMJS_BIN environement variable like this:
    >export PHANTOMJS_BIN=/Applications/phantomjs-1.9.0-macosx/bin/phantomjs