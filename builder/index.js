
var App = angular.module('compilejs-builder', []);

App.run(function($rootScope) {

  $rootScope.getMethod = function(name) {
    for(var i = 0; i < $rootScope.methods.length; i++)
      if($rootScope.methods[i].name === name)
        return $rootScope.methods[i];
    return null;
  };

  $rootScope.methods = [
    { name: 'init', args: [Object] },
    { name: 'get', args: [String, Function] },
    { name: 'set', args: [String, String] },
    { name: 'run', args: [String, Object] },
    { name: 'download', args: [String] }
  ];

  $rootScope.fields = [
    { method: $rootScope.getMethod('init'), args:['{ obj: true }'] },
    { method: $rootScope.getMethod('run'), args:['123','456'] }
  ];

  $rootScope.controllers = [];

  App.root = $rootScope;

});

App.controller('FieldController', function($scope) {

  console.log("init", $scope.field);

  $scope.controllers.push($scope);

  $scope.inputs = $.map($scope.field.method.args, function(str) {
    return {
      name: $scope.field.method.name,
      value: $scope.field.args.shift()
    };
  });

});








