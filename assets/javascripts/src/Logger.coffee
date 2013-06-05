define [
  'flog'
],
(flog)->
  class Logger
    @loggingLevel = window.loggingLevel ? 'all'
    @log =  (->
      temp = flog.create()
      temp.setLevel(Logger.loggingLevel)
      return temp
    )()

  return Logger