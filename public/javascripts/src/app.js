define([], function() {
  var App;

  return App = (function() {
    function App() {}

    App.prototype.hello = console.log("hello there, world");

    return App;

  })();
});

App;
