Package.describe({
  summary: "You don't call schema, schema calls you."
});

Package.on_use(function (api, where) {
  if(api.export) {
    api.use(['coffeescript', 'underscore', 'reactive-objects', 'validity'], ['client', 'server']);
    api.export('ReactiveSchema', ['client', 'server']);
  }
  api.add_files(['reactiveSchema.coffee', 'externals.coffee'], ['client', 'server']);
});

Package.on_test(function(api) {

  api.use('reactive-schema');
  api.use(['tinytest', 'validity', 'reactive-objects'], ['client', 'server']);

  api.add_files('reactiveSchema.test.js', ['client', 'server']);
});
