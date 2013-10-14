Package.describe({
  summary: "You don't call schema, schema calls you."
});

Package.on_use(function (api, where) {
  if(api.export) {
    api.use(['coffeescript'], ['client', 'server']);
    api.export('ReactiveSchema', ['client', 'server']);
  }
  api.add_files('reactiveSchema.coffee', ['client', 'server']);
});
