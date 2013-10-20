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
  obj._reactiveSchema = {}
  obj._reactiveSchema.changedLog = {}
  obj._reactiveSchema.schemaDeps = {}
  obj._reactiveSchema.schemaProperties = {}
  
  #schema properties setup.
  backendProp(obj, 'valid') #one way var, getter only
  obj._reactiveSchema.schemaProperties.valid = true #assume the object is valid before instantiation validations
  obj._reactiveSchema.schemaProperties.validLog = {}
  backendProp(obj, 'validationMessages') #one way var, getter only
  obj._reactiveSchema.schemaProperties.validationMessages = {}
  backendProp(obj, 'changed') #one way var, getter only
  obj._reactiveSchema.schemaProperties.changed = false #the object is new and is not changed

  #track changes for each property and if changed run validations and update object as needed.
  setProperty(obj, property, validationFunctions) for property, validationFunctions of schema
  #obj._reactiveSchema.schemaDeps.schema = Deps.autorun () -> validatate(obj, schema)    
  

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
  console.log obj[key]
  #Is this an array of functions?
  if value instanceof Array
    #Ho boy, we have some multi-validation going on here.
    for func in value
      #pass in the core object as this and give the key...
      output = func.call(obj, key)
      validateOutput(obj, key, output)
  #No, there is only one validation function.
  else
    #pass in the core object as this and give the key...
    output = value.call(obj,key)
    validateOutput(obj, key, output)
  return output

validateOutput = (obj, key, output) ->
  delete obj._reactiveSchema.schemaProperties.validationMessages[key] 
  #applied output, push the results to our 'reactive' vars
  if output.valid 
    obj._reactiveSchema.schemaProperties.validLog[key] = true
  else
    if obj.validationMessages[key] #if there are more then one validation functions this may already exist.
      obj._reactiveSchema.schemaProperties.validationMessages[key].push output.message # add the error message to the list.
    else #this is the first issue with this prop, possibly the only one.
      obj._reactiveSchema.schemaProperties.validationMessages[key] = [output.message] # add the error message. Always return an array, keeps things constant for the user.
    obj._reactiveSchema.schemaProperties.validLog[key] = false # we ain't valid no more.
  updateValidLog(obj)

setupChangeTracker = (obj, key, schema) ->
  validationFunctions = schema[key]
  obj._reactiveSchema.schemaDeps[key+'ChangeTracker'] = Deps.autorun () ->
    
    obj._reactiveDeps[key+'Deps'].depend() #we depend on this property's Deps 
    configValidation(key, validationFunctions, obj)
    if not this.firstRun 
      obj._reactiveSchema.changedLog[key] = true

ReactiveSchema.changedLog = (obj) -> 
  obj._reactiveSchema.changedLog

ReactiveSchema.resetChangedLog = (obj) ->
  for key of obj._reactiveSchema.changedLog
    obj._reactiveSchema.changedLog[key] = false

backendProp = (obj, propName) ->
  obj._reactiveSchema.schemaDeps[propName] = new Deps.Dependency
  Object.defineProperty obj, propName,
    get: () ->
      obj._reactiveSchema.schemaDeps[propName].depend()
      obj._reactiveSchema.schemaProperties[propName];  

updateValidLog = (obj) ->
  valids = _.values(obj._reactiveSchema.schemaProperties.validLog)
  if _.contains(valids, false) 
   obj._reactiveSchema.schemaProperties.valid = false
   obj._reactiveSchema.schemaDeps.valid.changed()
  else
    obj._reactiveSchema.schemaProperties.valid = true
    obj._reactiveSchema.schemaDeps.valid.changed()
