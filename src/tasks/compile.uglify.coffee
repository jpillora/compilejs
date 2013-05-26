unless compile?.task
  alert "Include Compile.js before tasks"


compile.task 'uglify', (config, callback) ->

  console.log "running uglify"

  @set config.dest, UglifyJS.minify config.src

  callback()

