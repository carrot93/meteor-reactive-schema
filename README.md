ReactiveSchema
======================

#### Philosophy: You don't call schema, schema calls you. 
This is a validation pattern that imbeds itself under your objects via [ReactiveObjects](https://github.com/CMToups/meteor-reactive-objects).
Unlike most schemas the validation is reactive. 
Just white-list your properties and listen to the reactive `object.valid` method. 
ReactiveSchema will also return reasons why the property is invalid. 
Best yet all the validations are just functions, so they can be a simple or complex as you need them to be.

## Instantiation

Create or add a schema to an object, `ReactiveSchema(object_needing_schema, schema)`

### Javascript Object
```
post = {}
ReactiveSchema( post, { title: [], content: [] } )
```

### Coffeescript Class
```coffee
class @post  
  constructor: -> 
    ReactiveSchema @, 
      title: []
      content: []
```

## Schema Object

