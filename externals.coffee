#move to new file
ReactiveSchema.changedLog = (obj) -> 
  obj._reactiveSchema.changedLog

ReactiveSchema.resetChangedLog = (obj) ->
  obj._reactiveSchema.changedLog = {}
