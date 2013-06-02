#task
compile.task 'coffee-script',

  fetch:
    CoffeeScript: "//cdnjs.cloudflare.com/ajax/libs/coffee-script/1.6.2/coffee-script.min.js"

  run: (config, callback) ->
    try
      out = CoffeeScript.compile config.src, config
    catch e
      callback "coffee-script: #{e.toString()}"
      return
    @set config.dest, out, true
    callback()

