define [
  'flog'
],
(flog)->
  class Logger
    @loggingLevel = window.loggingLevel ? 'silent'
    @log =  (->
      temp = flog.create()
      temp.setLevel(Logger.loggingLevel)
      return temp
    )()

  return Logger