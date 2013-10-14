#Public object
ReactiveSchema = (self, schema) -> 
  
  # Inbound
  # self -- core object to be validated
  # schema -- object of key / values: the keys are the core object white-listed properties, the values contain validation function(s)

  # Outbound
  # self._schema -- the schema saved for reference. -- !!! Not actually needed and could be pulled !!!
  # self._reactiveDeps.schemaDeps -- the schema Deps.autorun handle
  # self.valid -- is the core object's passing the schema validation? (boolean)
  # self.validationMessages -- object containing arrays of error messages if self.valid == false, same layout as schema 

  setUp(self, schema) #first run, fires once per object instantiation when in a class constructor.
  
  # add the reactive handle to the core object
  self._reactiveDeps.schemaDeps = 
    # run validation whenever object property updates
    #
    # !!! Currently this runs over all props on each prop change. Is this a good thing?  Doubtful... !!!
    #
    Deps.autorun () -> 
      #validate everything!
      validatate(self, schema) 

setUp = (self, schema) ->
  #make the schema a private property in the core object.
  self._schema = schema 

  #for every white-listed property in the schema ->
  # !!! this would be more efficient with Underscore's  _.keys() function !!!
  for key of self._schema 
    #setup as a reactive property 
    ReactiveObjects.setProperty(self, key) 
  # Add public api tools to the core object.
  ReactiveObjects.setProperties(self, ['valid', 'validationMessages']) 

validatate = (self, schema) ->
  #New validation, define or reset vars

  # innocent until proven guilty
  self.valid = true

  # Not a huge fan of this kind of reset but sub props were persisting
  delete self.validationMessages
  # this reset lets users test for bad property via `if self.validationMessages.property`
  self.validationMessages = {}

  # Run each property's validation(s) functions
  for key, value of self._schema
    #Is this an array of functions?
    if value instanceof Array
      #Ho boy, we have some multi-validation going on here.
      for func in value
        #pass in the core object as this and give the key...
        output = func.call(self, key)

        #apply the output to the core object
        validateOutput(self, key, output)
    #No, there is only one validation function.
    else
      #pass in the core object as this and give the key...
      output = value.call(self,key)

      #apply the output to the core object
      validateOutput(self, key, output)
  #Validation done


validateOutput = (self, key, output) ->
  #applied output, push the results to our 'reactive' vars
  unless output.valid #if the output is good then we don't have to do anything! GJ user.
    if self.validationMessages[key] #if there are more then one validation functions this may already exist.
      self.validationMessages[key].push output.message # add the error message to the list.
    else #this is the first issue with this prop, possibly the only one.
      self.validationMessages[key] = [output.message] # add the error message. Always return an array, keeps things constant for the user.
    self.valid = false # we ain't valid no more.
