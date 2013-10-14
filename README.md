meteor-reactive-schema
======================

You don't call schema, schema calls you.



# usage

class @post  
  constructor: -> 
    ReactiveSchema @, 
      title: []
      content: []
