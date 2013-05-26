

parseJSON = JSON.parse or $.parseJSON

#helpers
isArray = (obj) ->
  Object::toString.call(obj) is '[object Array]'

#compliation class
class Compilation

  constructor: ->
    #compilation wide values
    @values = {}
    @events = {}
    @dones = []
    @pending = 0

  #private api
  _ajax: (url, callback) ->
    #jquery version though could be swapped out...
    m = url.match /https?:\/\/[^\/]+/
    return @_err "ajax: Invalid URL: #{url}" unless m
    origin = m[0]

    if origin is window.location.origin
      $.ajax({url}).always (body, status, msg) ->
        callback status is 'error' and msg, body
    else
      $.ajax({
        url: 'http://compilejs.jpillora.com/retrieve',
        data: {url}
        dataType: 'jsonp'
      }).always (obj, status, msg) ->
        callback obj.body, obj.error

  _begin: -> @pending++
  _end: -> @pending--; @_check()
  _check: -> @_finish() if @pending is 0

  _finish: ->
    console.log "finish!"
    for done in @dones
      done.call @

  _on: (event, callback) ->
    unless @events[event]
      @events[event] = []
    @events[event].push callback

  _emit: (event, val)->
    callbacks = @events[event]
    return unless callbacks
    for callback in callbacks
      callback.call @, val

  _warn: (str) ->
    console.warn str

  _err: ->
    console.error str

  #public api
  _getAll: (names, callback) ->
    values = []
    for name, i in names
      ((i) =>
        @get name, (val) =>
          values[i] = val

          if names.length is values.length
            callback values
      )(i)

  get: (name, callback) ->
    @_begin()

    if isArray name
      @_getAll name, callback
      return

    gotValue = ->
      @_emit "get:#{name}"
      callback @values[name]
      @_end()

    if @values[name]
      setTimeout gotValue, 0
    else
      @_on "set:#{name}", gotValue

  set: (name, str) ->
    @_begin()

    if @values[name]
      return @_err "set: '#{name}' already exists"

    gotValue = (val) =>
      @values[name] = val
      @_emit "set:#{name}"
      @_end()

    if /\s/.test str
      setTimeout (-> gotValue(str)), 0
    else
      @_ajax str, gotValue

    @

  download: (name) ->
    @get name, (val) =>
      $("<form method='post'></form>")
        .attr('action', 'http://compilejs.jpillora.com/download?filename='+encodeURIComponent(name)+'.js')
        .append($("<textarea name='__compilejsDownload'></textarea>").html(val))
        .submit()
    @_check()
    @


  run: (name, config) ->
    @_begin()

    task = tasks[name]

    unless task
      return @_err "run: Missing task '#{name}'"

    gotSrc = (src) =>
      config.src = src
      task.run.call @, config, (err) =>
        if err
          @_err "run: #{name}: #{err}"
        @_end()

    if config.src
      @get config.src, gotSrc
    else
      setTimeout gotSrc, 0
    @

  done: ->
    if arguments.length is 0
      return @_err "done: Missing callback"

    gets = Array::slice.call arguments
    done = names.pop()
    dones.push { done, gets }
    @

#library wide tasks
tasks = {}

#public api
compile =
  init: -> new Compilation
  task: (name, def) ->

    if tasks[name]
      @_warn "task: '#{name}' already exists "

    if typeof def is "function"
      def = {run: def}
    else if not def or typeof def.run isnt "function"
      return @_err "task: '#{name}' Missing function"

    tasks[name] = def

#publicise
if typeof exports is "object"
  module.exports = compile
else if typeof define is "function" && define.amd
  define -> compile
else
  window.compile = compile
