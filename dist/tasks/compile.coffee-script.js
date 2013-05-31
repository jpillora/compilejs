// Generated by CoffeeScript 1.6.2
(function() {
  compile.task('coffee-script', {
    fetch: {
      CoffeeScript: "//cdnjs.cloudflare.com/ajax/libs/coffee-script/1.6.2/coffee-script.min.js"
    },
    run: function(config, callback) {
      var e, out;

      try {
        out = CoffeeScript.compile(config.src, config);
      } catch (_error) {
        e = _error;
        callback("coffee-script: " + (e.toString()));
        return;
      }
      this.set(config.dest, out);
      return callback();
    }
  });

}).call(this);
