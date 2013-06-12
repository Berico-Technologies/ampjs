define [
  'flog'
],
(flog)->
  class Logger
    @loggingLevel = window.loggingLevel ? 'none'
    @log =  (->
      temp = flog.create()
      temp.setLevel(Logger.loggingLevel)
      return temp
    )()

  return Logger