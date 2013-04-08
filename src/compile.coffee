

transforms:
  uglify:
    name: 'UglifyJS'
    src: 'lib/uglify.js'
    transform: (input) ->
      output = "var foo = 42;"


class Compilation
  
  defaults: {}

  constructor: (@config) ->

  compile: ->
