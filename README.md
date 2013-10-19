ReactiveSchema
======================

#### Philosophy: You don't call schema, schema calls you. 
This is a validation pattern that imbeds itself under your objects via [ReactiveObjects](https://github.com/CMToups/meteor-reactive-objects).
Unlike most schemas the validation is reactive. 
Just white-list your properties and listen to the reactive `object.valid` method. 
ReactiveSchema will also return reasons why the property is invalid. 
Best yet, all the validations are just functions, so it can be as simple or complex as you need them to be.

Note: This api, and its dependencies are all still in flux and will be until they have a full test base and are 1.0.0. 

####  Dependencies
[ReactiveObjects](https://github.com/Meteor-Reaction/meteor-reactive-objects) [![Build Status](https://travis-ci.org/Meteor-Reaction/meteor-reactive-objects.png)](https://travis-ci.org/Meteor-Reaction/meteor-reactive-objects)
<br>
[Validity](https://github.com/Meteor-Reaction/meteor-validity) [![Build Status](https://travis-ci.org/Meteor-Reaction/meteor-validity.png)](https://travis-ci.org/Meteor-Reaction/meteor-validity)

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

  Note: this is most likely going to change, I think it has a smell.

These are any functions which return `Validity.allow()` or `Validity.deny()`. 
Check out [Validity](https://github.com/CMToups/meteor-validity)  for more details.

Validity, in this package, api : `function (property) {}`

The `this` context is that of your calling object. 
This so you can get any of the keys values if you wish to test for there existence.
The inbound `property` var is the name of the key of the property being tested.
You can get the value of the property being tested with `this[property]`

An example function:
```coffee
isString = (property) ->
  unless _.isString(this[property]) then return Validity.deny('must be a string')
  Validity.allow()
```

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

#### If you're so inclined
[![Support via Gittip](https://rawgithub.com/twolfson/gittip-badge/0.1.0/dist/gittip.png)](https://www.gittip.com/cmtoups/)



