// Generated by CoffeeScript 1.6.2
(function() {
  var Compilation;

  ({
    transforms: {
      uglify: {
        name: 'UglifyJS',
        src: 'lib/uglify.js',
        transform: function(input) {
          var output;

          return output = "var foo = 42;";
        }
      }
    }
  });

  Compilation = (function() {
    Compilation.prototype.defaults = {};

    function Compilation(config) {
      this.config = config;
    }

    Compilation.prototype.compile = function() {};

    return Compilation;

  })();

}).call(this);
