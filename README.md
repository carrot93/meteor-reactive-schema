ReactiveSchema
======================

#### Philosophy: You don't call schema, schema calls you. 
This is a validation pattern that imbeds itself under your objects via [ReactiveObjects](https://github.com/CMToups/meteor-reactive-objects).
Unlike most schemas the validation is reactive. 
Just white-list your properties and listen to the reactive `object.valid` method. 
ReactiveSchema will also return reasons why the property is invalid. 
Best yet, all the validations are just functions, so it can be as simple or complex as you need them to be.

####  Dependencies
[ReactiveObjects](https://github.com/CMToups/meteor-reactive-objects) <br>
[Validity](https://github.com/CMToups/meteor-validity) - Can be made a weak dependance on request.

## Instantiation

Create or add a schema to an object, `ReactiveSchema(object_needing_schema, schema)`

### Javascript Object
```javascript
post = {}
schema = { title: [], content: [] }
ReactiveSchema( post, schema )
```

### Coffeescript Class
```coffee

schema =
  title: []
  content: []

class @post  
  constructor: -> 
    ReactiveSchema @, schema
```

## Schema Object

The schema object is rather strait forward. 
Define your properties with the keys and add your validation functions to the values.

```javascript

//Assuming isSet, isString, and isSafe are all validation functions.

schema = {
  title: isString
  meta: [isSet]
  content: [isString, isSafe]
}
```




