ReactiveSchema.changedLog = (obj) -> 
  obj._reactiveSchema.changedLog

ReactiveSchema.resetChangedLog = (obj) ->
  obj._reactiveSchema.changedLog = {}
