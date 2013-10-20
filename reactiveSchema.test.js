isTrue = function () {
  return Validity.allow()
}

isFalse = function () {
  return Validity.deny('message')
}

//instantiate
Tinytest.add('ReactiveSchema - public api - instantiate embeds the schema into the object', function(test) {
  obj = {}
  schema = { title: [], content: [] } //may as well test everything at once, if this fails isolate the reason and put it in a fresh test.
  ReactiveSchema(obj, schema)
  test.isTrue(obj.hasOwnProperty('title'), 'sets the first property')
  test.isTrue(obj.hasOwnProperty('content'), 'sets the second property')
});

//valid
Tinytest.add('ReactiveSchema - public api - valid reacts to the schema', function(test) {

  //no validations so it can be invalid
  obj = {}
  schema = {}
  ReactiveSchema(obj, schema)
  test.isTrue(obj.valid, 'should return true')

  //passing validations should be valid
  obj = {}
  schema = { title: [isTrue] }
  ReactiveSchema(obj, schema)
  test.isTrue(obj.valid, 'should return true')

  //failing validations should not be valid
  obj = {}
  schema = { title: [isFalse] }
  ReactiveSchema(obj, schema)
  test.isFalse(obj.valid, 'should return false')
});

//message
Tinytest.add('ReactiveSchema - public api - message reacts to the schema', function(test) {
  //valid objects should not have a invalidation reason message
  obj = {}
  schema = { title: [isTrue] }
  ReactiveSchema(obj, schema)
  test.isFalse(obj.validationMessages.hasOwnProperty('title') ,'should return false')
  
  //invalid objects should have a invalidation reason message
  obj = {}
  schema = { title: [isFalse] }
  ReactiveSchema(obj, schema)
  test.equal(obj.validationMessages.title[0], 'message' ,'should return the invalidation reason message')
});

//changedLog
Tinytest.add('ReactiveSchema - public api - changedLog shows which properties have changed', function(test) {
  obj = {}
  schema = { title: [] }
  ReactiveSchema(obj, schema)
  test.equal(ReactiveSchema.changedLog(obj), {title: false}, 'should return no changes')
  obj.title = 'test'
  Deps.flush()
  test.equal(ReactiveSchema.changedLog(obj), {title: true}, 'should return a change')
});

//resetChangedLog
Tinytest.add('ReactiveSchema - public api - resetChangedLog sets all change log observers to false', function(test) {
  obj = {}
  schema = { title: [] }
  ReactiveSchema(obj, schema)
  obj.title = 'test'
  Deps.flush()
  test.equal(ReactiveSchema.changedLog(obj), {title: true}, 'should return a change')
  ReactiveSchema.resetChangedLog(obj)
  Deps.flush()
  test.equal(ReactiveSchema.changedLog(obj), {title: false}, 'should return no changes')
});

