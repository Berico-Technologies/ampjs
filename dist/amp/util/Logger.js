define(['flog'], function(flog) {
  var Logger;
  Logger = (function() {
    var _ref;

    function Logger() {}

    Logger.loggingLevel = (_ref = window.loggingLevel) != null ? _ref : 'none';

    Logger.log = (function() {
      var temp;
      temp = flog.create();
      temp.setLevel(Logger.loggingLevel);
      return temp;
    })();

    return Logger;

  })();
  return Logger;
});
