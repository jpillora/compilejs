
var App = angular.module('compilejs-builder', []);

App.run(function($rootScope, $timeout) {
  App.root = $rootScope;

  $rootScope.codeShown = false;

  $rootScope.getMethod = function(name) {
    for(var i = 0; i < $rootScope.methods.length; i++)
      if($rootScope.methods[i].name === name)
        return $rootScope.methods[i];
    return null;
  };

  $rootScope.methods = [
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
      ] },
    { name: 'options',
      inputs: [
        {type:'json', placeholder: 'configuration object'}
      ] }
  ];

  $rootScope.fields = [];

  $rootScope.addField = function() {
    $rootScope.fields.push({ method: null, args: [] });

    $timeout($rootScope.update, 10);

  };

  $rootScope.toggleCode = function() {
    $rootScope.codeShown = !$rootScope.codeShown;
    $rootScope.updateCode();
  };

  $rootScope.updateCode = function() {

    var code = "compile";

    $.each($rootScope.fields, function(i, f) {

      var method = f.method;
      if(f.disabled || !method || !method.name )
        return;

      var args = [];
      $.each(f.args, function(i, arg) {
        var input = method.inputs[i];
        var str = null;
        if(input.type === 'json' ||
           input.type === 'fn') {
          try {
            new Function("("+arg+")");
          } catch(e) {
            return;
          }
          str = arg.replace(/\n/gm, '\n  ');
        } else {
          str = JSON.stringify(arg);
        }
        args.push(str);
      });

      code += ".\n  " + method.name + "(" + args.join(", ") + ")";
    });

    $rootScope.code = code;
  };


  $rootScope.run = function() {
    console.log("run");
  };

  $rootScope.del = function(index) {
    $rootScope.fields.splice(index, 1);
  };

  $rootScope.update = function() {
    $rootScope.updateCode();
    $rootScope.updateEditors();
  };

  $rootScope.updateEditors = function() {
    $("textarea:not(.codemirrored):visible").each(function() {
      CodeMirror.fromTextArea(this, {
        lineNumbers: true,
        viewportMargin: Infinity
      });
      $(this).addClass("codemirrored");
    });
  };
});

App.controller('ConfigController', function($scope, $rootScope, $timeout) {

  $rootScope.configCtrl = $scope;

  $scope.preset = null;
  $scope.showImport = false;

  $scope.presets = [
    { name: "Compile.js", file: "compilejs"},
    { name: "Minify Compile.js", file: "compilejs-min"}
  ];

  $scope.updatedPreset = function() {
    if(!$scope.preset) return;
    $.getJSON("presets/" + $scope.preset.file + ".json", $scope.loadFields);
    $scope.preset = null;
  };

  //grab the method objects
  $scope.loadFields = function(fields) {
    if(!$.isArray(fields)) {
      alert("Fields must be an array");
      return;
    }
    var fs = [];
    $.each(fields, function(i, f) {
      f.method = $scope.getMethod(f.method);
      fs.push(f);
    });
    $rootScope.fields = fs;
    $timeout(function() {
      $rootScope.update();
      $rootScope.$apply();
    });
  };

  $scope.export = function() {
    str = JSON.stringify(App.root.fields, function(k,v) {
      if(k === "method") return v.name;
      if(/^\$/.test(k)) return;
      return v;
    }, 2);
    compile.set('data', str).download('data', 'export.json');
  };

  $scope.import = function() {
    var fields = null;
    try {
      fields = JSON.parse($scope.importData);
    } catch(e) {
      alert("Invalid JSON");
      return;
    }
    $scope.loadFields(fields);
  };

});

