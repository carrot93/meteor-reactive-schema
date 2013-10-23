ReactiveSchema [![Build Status](https://travis-ci.org/Meteor-Reaction/meteor-reactive-schema.png)](https://travis-ci.org/Meteor-Reaction/meteor-reactive-schema)
======================

#### Philosophy: You don't call schema, schema calls you. 
This is a validation pattern that imbeds itself under your objects via [ReactiveObjects](https://github.com/CMToups/meteor-reactive-objects).
Unlike most schemas the validation is reactive. 
Just white-list your properties and listen to the reactive `object.valid` method. 
ReactiveSchema will also return reasons why the property is invalid. 
You can use it on both the server and the client, and it can extend existing objects or create new ones.
Best yet, all the validations are just functions, so it can be as simple or complex as you need them to be.

Note: This api, and its dependencies are all still in flux and will be until they have a full test base and are 1.0.0. 

####  Dependencies
[![Build Status](https://travis-ci.org/Meteor-Reaction/meteor-reactive-objects.png)](https://travis-ci.org/Meteor-Reaction/meteor-reactive-objects)
[ReactiveObjects](https://github.com/Meteor-Reaction/meteor-reactive-objects)
<br>
[![Build Status](https://travis-ci.org/Meteor-Reaction/meteor-validity.png)](https://travis-ci.org/Meteor-Reaction/meteor-validity)
[Validity](https://github.com/Meteor-Reaction/meteor-validity) 

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

## Schema

### Schema Object

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
### Validation objects

These are any functions which return `Validity.allow()` or `Validity.deny()`. 
Check out [Validity](https://github.com/CMToups/meteor-validity)  for more details.

Validity api (in this package): `function (object, property) {}`

There are currenly two ways to write validation functions:

* 1 For maximum reusability, you can manually include Validity in you project. 
  You can then uses these like any other Validity function.

* 2 You can opt out of using Validity and use these functions with just ReactiveSchema.
  The `this` context is Validity itself. So you can call `this.allow()` and `this.deny()`
  Naturally these functions will throw an exception if used outside of the schema.


The inbound `object` var is the object being validated.
The inbound `property` var is the name of the key of the property being tested.

You can get the value of the property being tested with `object[property]`.

An example function (with underscore):
```javascript
isString = function (object, property) {
  if (!_.isString(object[property])) 
    return Validity.deny('must be a string')
  else
    return Validity.allow()
}
```
### API 

#### ReactiveSchema( object, schema )
  Used to create or extend objects with the reactive schema. 
  
  The resulting object have the following additional reactive properties.

* object.valid
  * If all the schema functions are passing it will return true, else it returns false.

* object.validationMessages
  * Returns an object. If there are no issue with validation it returns an empty object ( {} ).
    Each property that is invalid will be a property of this object.
    Each property will be an array of strings. Each string is an issue with the property, 
    these strings are returned from Validity.

* object.changed
  * If any of the properties in the schema have change this will be true, else it returns false

#### ReactiveSchema.changedLog(object)
  * Returns and object with all the properties in the schema. 
    The properties will be true if they have changed or false if they have not.
    object.changed will be set to true if any of these properties are true.

#### ReactiveSchema.resetChangedLog(object)
  * Sets all the properties in the changedLog to false; object.changed will become false if it is not already.

### Handlebars example
Assuming `Template.example.post = post`
```html

<!-- You would likely use a handlebars helper to clean this up. -->

{{#unless post.valid}}
  Your post has some errors:
  {{#if post.validationMessages.title}}
    Title {{post.validationMessages.title}}
  {{/if}}
{{/unless}}

```

### ChangeLog

* v0.1.0: Validation functions have completely change from its old smelly style

#### If you're so inclined
[![Support via Gittip](https://rawgithub.com/twolfson/gittip-badge/0.1.0/dist/gittip.png)](https://www.gittip.com/cmtoups/)



