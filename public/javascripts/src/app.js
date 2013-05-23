define([], function() {
  var App;

  return App = (function() {
    function App() {}

    App.prototype.hello = console.log("hello there, planet earth");

    return App;

  })();
});

App;
