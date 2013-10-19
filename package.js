Package.describe({
  summary: "You don't call schema, schema calls you."
});

Package.on_use(function (api, where) {
  if(api.export) {
    api.use(['coffeescript', 'underscore', 'reactive-objects', 'validity'], ['client', 'server']);
    api.export('ReactiveSchema', ['client', 'server']);
    api.imply('validity', ['client', 'server'])
  }
  api.add_files('reactiveSchema.coffee', ['client', 'server']);
});

Package.on_test(function(api) {

  api.use('reactive-schema');
  api.use(['tinytest'], ['client', 'server']);

  api.add_files('reactiveSchema.test.js', ['client', 'server']);
});
