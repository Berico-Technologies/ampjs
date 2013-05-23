define([], function() {
  var App;

  return App = (function() {
    function App() {}

    App.prototype.hello = console.log("hello world");

    return App;

  })();
});

App;
