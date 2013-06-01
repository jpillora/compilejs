
var App = angular.module('compilejs-builder', []);

App.run(function($rootScope) {
  App.root = $rootScope;

  $rootScope.codeShown = false;

  $rootScope.getMethod = function(name) {
    for(var i = 0; i < $rootScope.methods.length; i++)
      if($rootScope.methods[i].name === name)
        return $rootScope.methods[i];
    return null;
  };

  $rootScope.methods = [
    { name: 'init',
      inputs: [
        {type:'json', placeholder: 'configuration object'}
      ] },
    { name: 'get',
      inputs: [
        {type:'short', placeholder: 'value name'},
        {type:'fn', def: 'function(val) { /*use value here */ }'}
      ] },
    { name: 'set',
      inputs: [
        {type:'short', placeholder: 'value name'},
        {type:'long', placeholder: 'url or code'}
      ] },
    { name: 'run',
      inputs: [
        {type:'short', placeholder: 'task name'},
        {type:'json', placeholder: 'task configuration object'}
      ] },
    { name: 'download',
      inputs: [
        {type:'short', placeholder: 'value name'}
      ] }
  ];

  $rootScope.fields = [];

  //grab the method objects
  $rootScope.loadFields = function(fields) {
    $rootScope.fields = $.map(fields, function(f) {
      f.method = $rootScope.getMethod(f.method);
    });
  };

  $.each($rootScope.fields, function(i, f) {
    f.method = $rootScope.getMethod(f.method);
  });

  $rootScope.addField = function() {
    $rootScope.fields.push({ method: null, args: [] });
    $rootScope.updateCode();
  };

  $rootScope.toggleCode = function() {
    $rootScope.codeShown = !$rootScope.codeShown;
    $rootScope.updateCode();
  };

  $rootScope.updateCode = function() {

    var fields = [];

    $.each($rootScope.fields, function(i, f) {

      var method = f.method;
      if(f.disabled || !method || !method.name )
        return;

      var args = [];
      $.each(f.args, function(i, arg) {
        var type = method.inputs[i];
        args.push(JSON.stringify(arg));
      });

      fields.push("  " + method.name + "(" + args.join(", ") + ")");
    });

    $rootScope.code = "compile.\n" + fields.join(".\n");
  };


  $rootScope.run = function() {
    console.log("run");
  };

  $rootScope.update = function() {
    $rootScope.updateCode();
  };

  $rootScope.del = function(index) {
    $rootScope.fields.splice(index, 1);
  };

});

