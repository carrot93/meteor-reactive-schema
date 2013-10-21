#Public object
ReactiveSchema = (obj, schema) -> 
  
  # Inbound
  # obj -- core object to be validated
  # schema -- object of key / values: the keys are the core object white-listed properties, the values contain validation function(s)

  # Outbound
  # obj._reactiveSchema -- the schema object for config options and hidden storage. 
  # obj.valid -- (boolean) is the core object's passing the schema validation? (boolean)
  # obj.validationMessages -- object containing arrays of error messages, same layout as schema 
  # obj.changed -- (boolean) has any props changed since instantiation?
  
  #set up core frame
  obj._reactiveSchema = 
    changedLog: {}
    validLog: {}

  #schema properties setup.
  backendProperties(obj, ['valid', 'validationMessages', 'changed']) #one way vars, getter only
  obj._reactiveProperties =
    valid: true #assume the object is valid before instantiation validations
    validationMessages: {}
    changed: false #the object is new and is not changed

  #track changes for each property and if changed run validations and update object as needed.
  setProperty(obj, property, validationFunctions) for property, validationFunctions of schema
  

  obj #end cleanly

setProperty = (obj, key, validationFunctions) ->
  firstRun = {} 
  firstRun[key] = true #first-run, test on a key basis
  overriedObj = {} #reactiveObjects mixin functions
  overriedObj.beforeSet = (obj, value) -> 
    if firstRun[key] #if is first run, turn of first-run var and continue
      firstRun[key] = false
      return true
    else if obj._reactiveProperties[key] != value #if not first run and value is not changed, stop!
      obj._reactiveSchema.changedLog[key] = true #if value is changed, fire changed and continue
      return true
    return false
  overriedObj.afterSet = (obj, value) -> 
      configValidation(key, validationFunctions, obj)

  ReactiveObjects.setProperty obj, key, overriedObj # sets up properties on the object

configValidation = (key, value, obj) ->
  if value instanceof Array
    for func in value
      output = func.call(obj, key)
      validateOutput(obj, key, output)
  else
    output = value.call(obj,key)
    validateOutput(obj, key, output)
  return output

validateOutput = (obj, key, output) ->
  if output.valid 
    obj._reactiveSchema.validLog[key] = true
  else
    if obj.validationMessages[key] #if there are more then one validation functions this may already exist.
      obj._reactiveProperties.validationMessages[key].push output.message 
    else #this is the first issue with this prop, possibly the only one.
      obj._reactiveProperties.validationMessages[key] = [output.message] # add the error message. Always return an array, keeps things consistent for the user.
    obj._reactiveSchema.validLog[key] = false 
  updateValidLog(obj)
  updateChangedLog(obj)

ReactiveSchema.changedLog = (obj) -> 
  obj._reactiveSchema.changedLog

ReactiveSchema.resetChangedLog = (obj) ->
  for key of obj._reactiveSchema.changedLog
    obj._reactiveSchema.changedLog[key] = false

backendProperties = (obj, properties) ->
  for property in properties
    overrideObj = {} #reactiveObjects mixin functions
    overrideObj.beforeSet = (obj, value) -> 
      return false
    overrideObj.afterSet = (obj, value) -> 
    ReactiveObjects.setProperty obj, property, overrideObj

updateValidLog = (obj) ->
  valids = _.values(obj._reactiveSchema.validLog)
  if _.contains(valids, false) 
   obj._reactiveProperties.valid = false
   obj._reactiveDeps.validDeps.changed()
  else
    obj._reactiveProperties.valid = true
    obj._reactiveDeps.validDeps.changed()

updateChangedLog = (obj) ->
  changes = _.values(obj._reactiveSchema.changedLog)
  if _.contains(changes, true) 
    obj._reactiveProperties.changed = true
    obj._reactiveDeps.changedDeps.changed()
  else
    obj._reactiveProperties.changed = false
    obj._reactiveDeps.changedDeps.changed()
