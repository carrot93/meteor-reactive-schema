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
  
  #set up core frame, these allow for arrogation
  obj._reactiveSchema = 
    changedLog: {}
    validLog: {}

  #schema properties setup, sets the object default values
  backendProperties(obj, ['valid', 'validationMessages', 'changed']) #one way vars, getter only
  obj._reactiveProperties = #effectively the only setter.
    valid: true
    validationMessages: {}
    changed: false

  #track changes for each property and if changed run validations and update object as needed.
  setProperty(obj, property, validationFunctions) for property, validationFunctions of schema
  
  obj #its good form to end cleanly

setProperty = (obj, key, validationFunctions) ->
  firstRun = {} 
  firstRun[key] = true #first-run, test on a key basis
  overrideObj = {} #reactiveObjects mixin functions

  #track if value has changed after instantiation. (useful for db updating)
  overrideObj.set = (setter) -> 
    if firstRun[key] then firstRun[key] = false #if is first run, turn off first-run var and continue
    else if setter.oldValue != setter.value #if not first run and value is not changed, stop!
      obj._reactiveSchema.changedLog[key] = true #if value is changed, fire changed and continue
      updateChangedLog(obj)
    validations(setter, validationFunctions, key, obj)

  #Setup done, do your work O' mighty Reactive Object! (end of instantiation)
  ReactiveObjects.setProperty obj, key, overrideObj 

validations = (setter, validations, key, obj) ->
  if validations instanceof Array
    for func in validations
      output = func.call(Validity, setter.value, key, obj)
      distributeOutput(obj, key, output)
  else
    output = validations.call(Validity, setter.value, key, obj)
    distributeOutput(obj, key, output)
  return output

distributeOutput = (obj, key, output) ->
  delete obj._reactiveProperties.validationMessages[key]
  if output.valid 
    obj._reactiveSchema.validLog[key] = true
  else
    if obj._reactiveProperties.validationMessages[key] #if there are more then one validation functions this may already exist.
      obj._reactiveProperties.validationMessages[key].push output.message 
    else #this is the first issue with this prop, possibly the only one.
      obj._reactiveProperties.validationMessages[key] = [output.message] # add the error message. Always return an array, keeps things consistent for the user.
    obj._reactiveSchema.validLog[key] = false 
  updateValidLog(obj)

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

backendProperties = (obj, properties) ->
  for property in properties
    overrideObj = {} #reactiveObjects mixin functions
    overrideObj.set = (setter) -> setter.stop = true
    ReactiveObjects.setProperty obj, property, overrideObj


ReactiveSchema.changedLog = (obj) -> 
  obj._reactiveSchema.changedLog

ReactiveSchema.resetChangedLog = (obj) ->
  obj._reactiveSchema.changedLog = {}
  updateChangedLog(obj)
