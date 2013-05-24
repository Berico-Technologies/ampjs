define [
  'flog'
],
(flog)->
  class Logger
    @loggingLevel = 'debug'
    @log =  (->
      temp = flog.create()
      temp.setLevel(Logger.loggingLevel)
      return temp
    )()

  return Logger