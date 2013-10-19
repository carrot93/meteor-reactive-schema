#Public object
ReactiveSchema = (obj, schema) -> 
  
  # Inbound
  # obj -- core object to be validated
  # schema -- object of key / values: the keys are the core object white-listed properties, the values contain validation function(s)

  # Outbound
  # obj._reactiveSchema -- the schema object for config options and hidden storage. 
  # obj.valid -- is the core object's passing the schema validation? (boolean)
  # obj.validationMessages -- object containing arrays of error messages if obj.valid == false, same layout as schema 
  
  #set up core frame
  obj._reactiveSchema = {}
  obj._reactiveSchema.changedLog = {}
  obj._reactiveSchema.changedDeps = {}

  #do work
  ReactiveObjects.setProperties(obj, _.keys(schema)) 
  setupValid(obj, schema)
  setupValidationMessages(obj, schema)
  setupChangedLog(obj, schema)

  obj #end cleanly

setupValid = (obj, schema) ->
  backendProp(obj, 'valid')
  obj._reactiveSchema.schemaDeps = 
    Deps.autorun () -> validatate(obj, schema)  

setupValidationMessages = (obj, schema) ->
  backendProp(obj, 'validationMessages')

setupChangedLog = (obj, schema) ->
  backendProp(obj, 'changed')
  for key of schema
    obj._reactiveSchema.changedLog[key] = false 
  trackChanges(obj) 

validatate = (obj, schema) ->
  #New validation, define or reset vars

  # innocent until proven guilty
  obj.valid = true

  # Not a huge fan of this kind of reset but sub props were persisting
  delete obj.validationMessages
  # this reset lets users test for bad property via `if obj.validationMessages.property`
  obj.validationMessages = {}

  # Run each property's validation(s) functions
  for key, value of schema
    #Is this an array of functions?
    if value instanceof Array
      #Ho boy, we have some multi-validation going on here.
      for func in value
        #pass in the core object as this and give the key...
        output = func.call(obj, key)

        #apply the output to the core object
        validateOutput(obj, key, output)
    #No, there is only one validation function.
    else
      #pass in the core object as this and give the key...
      output = value.call(obj,key)

      #apply the output to the core object
      validateOutput(obj, key, output)
  #Validation done


validateOutput = (obj, key, output) ->
  #applied output, push the results to our 'reactive' vars
  unless output.valid #if the output is good then we don't have to do anything! GJ user.
    if obj.validationMessages[key] #if there are more then one validation functions this may already exist.
      obj.validationMessages[key].push output.message # add the error message to the list.
    else #this is the first issue with this prop, possibly the only one.
      obj.validationMessages[key] = [output.message] # add the error message. Always return an array, keeps things constant for the user.
    obj.valid = false # we ain't valid no more.

trackChanges = (obj) ->
  for own key of ReactiveObjects.getObjectProperties(obj)
    unless (key == 'valid') or (key == 'validationMessages')
      setupTracker(obj, key)

setupTracker = (obj, key) ->
  obj._reactiveSchema.changedDeps[key] = Deps.autorun () ->
    obj._reactiveDeps[key + "Deps"].depend()
    if not this.firstRun 
      obj._reactiveSchema.changedLog[key] = true

ReactiveSchema.changedLog = (obj) -> 
  obj._reactiveSchema.changedLog

ReactiveSchema.resetChangedLog = (obj) ->
  for key of obj._reactiveSchema.changedLog
    obj._reactiveSchema.changedLog[key] = false

backendProp = (obj, prop) ->
  ReactiveObjects.setProperty(obj, prop) 
