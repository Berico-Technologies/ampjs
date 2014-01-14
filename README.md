AMPJS
=====
AMPJS is a Javascript [STOMP]-based client for [AMP]. It integrates with a route provider (such as Berico's Global Topology Service) and a authentication provider (such as Berico's Anubis) to provide a dynamic and scalable messaging solution. Here's a quick [writeup] that should give you an overview of the client


![architecture diagram](https://raw.github.com/Berico-Technologies/ampjs/develop/docs/amp_architecture.png)


#Overview
This project is packaged as a [BOWER](https://github.com/bower/bower) module but is not listed in the bower repo. To install a particular version (in this case version 0.0.21) of this project through bower you will need run a command like this:
```
bower install https://github.com/Berico-Technologies/ampjs.git#0.0.21
```
#Installation
AMPJS can be integrated into your project in one of thee ways:
- [Shim With Dependencies] contains the entire library with an Almond AMD shim and a wrapper. AMPJS is accessable as a global property to be used in containing apps.
- [No Shim No Dependencies] is intended to be used by other RequireJS applications, but does not contain any of the libraries AMPJS depends on (you're responsible for providing them yourself).
- [No Shim With Dependencies] is intended to be used by other RequireJS applications, and contains all the libraries AMPJS depends on.

##Quick 'n Dirty (shim with dependencies)
```
<html>
  <head>
    <script src="ShortBus.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    var shortBus = ShortBus.getBus({
      exchangeProviderHostname: "gts.example.mil",
      exchangeProviderPort: 15677,
      routingInfoHostname: "gts.example.mil",
      routingInfoPort: 15677,
      authenticationProviderHostname: "anubis.example.mil",
      authenticationProviderPort: 15678,
      fallbackTopoExchangeHostname: "rabbit.example.mil",
      fallbackTopoExchangePort: 15680,
      busType: 'event'
    });
    shortBus.subscribe({
      getEventType: function() {
        return "my.cool.topic";
      },
      handle: function(event, headers) {
        document.body.innerHTML = event.body;
      },
      handleFailed: function(envelope, exception) {
        return console.log("Event failure");
      }
    }).then(function(){
      shortBus.publish({'body':'interesting stuff...'},'my.cool.topic');
    });
    </script>
  </head>
  <body>
  </body>
</html>
```
The above example is the simplest possbile AMPJS use. It will publish to the topic "my.cool.topic" after a listener has been registered to the same topic. If the message was sent and received correctly the message "interesting stuff..." should display on the page.

##A full example with RequireJS (no shim no dependencies)
In this example the developer is responsible for supplying the supporting libraries on which AMPJS depends.

### RequireJS Configuration
The required dependencies should be brought into the project as part of the initial bower install, however you will need to define the installed libraries with appropriate keys for AmpJS to find them:
```
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
  jquery: 'vendor/managed/jquery/jquery',
  shortBus: 'vendor/managed/ampjs/ShortBus.min'
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
```

###Client Configuration
Assuming you followed the above example and aliased AmpJS to 'ShortBus,' here is how you would instantiate the client and publish / subscribe to a topic. In this example we will use the RPC bus rather than the pub/sub bus shown above **Note that in this example messages are not published on the topic until the subscriber's deferred is resolved. Any messages published on the topic before the subscriber is initialized will not be received by the client**

```
define(['ShortBus'], function(ShortBus) {
  var shortBus = ShortBus.getBus({
    exchangeProviderHostname: "gts.example.mil",
    exchangeProviderPort: 15677,
    routingInfoHostname: "gts.example.mil",
    routingInfoPort: 15677,
    authenticationProviderHostname: "anubis.example.mil",
    authenticationProviderPort: 15678,
    fallbackTopoExchangeHostname: "rabbit.example.mil",
    fallbackTopoExchangePort: 15680,
    busType: 'event'
  });
  shortBus.getResponseTo({
    request: {
      body: "interesting data..."
    },
    outboundTopic: "my.cool.outbound",
    inboundTopic: "my.cool.inbound"
  }).then(function(data) {
    document.body.innerHTML = event.body;
  });
});
```
In the above example a message will be sent to a server-side service listening to the topic "my.cool.outbound". The client will listen for a response on "my.cool.inbound" and, when it receives a response it will print the contents to the page.



Running Tests
-------------
AMPJS is integrated with Mimosa and Karma to run its test automatically. You can run the tests by watching the project:
```
mimosa watch
```

[STOMP]: http://jmesnil.net/stomp-websocket/doc/
[AMP]: https://github.com/Berico-Technologies/AMP
[No Shim No Dependencies]: https://github.com/Berico-Technologies/ampjs/blob/master/build/noShimNoDependencies/ShortBus.min.js
[No Shim With Dependencies]: https://github.com/Berico-Technologies/ampjs/blob/master/build/noShimWithDependencies/ShortBus.min.js
[Shim With Dependencies]: https://github.com/Berico-Technologies/ampjs/blob/master/build/shimmedWithDependencies/ShortBus.min.js
[writeup]: https://raw.github.com/Berico-Technologies/ampjs/develop/docs/AmpJSWebClient.docx