ReactiveSchema
======================

#### Philosophy: You don't call schema, schema calls you. 
This is a schema that imbeds itself under your objects via [ReactiveObjects](https://github.com/CMToups/meteor-reactive-objects).

## Instantiation

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
