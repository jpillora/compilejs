

parseJSON = JSON.parse or $.parseJSON

#helpers
isArray = (obj) ->
  Object::toString.call(obj) is '[object Array]'

#chrome a.download
saveAs = (name, text) ->
  a = document.createElementNS("http://www.w3.org/1999/xhtml", "a")
  return false  unless "download" of a
  blob = new window.Blob([text],
    type: "text/plain;charset=utf8"
  )
  a.href = window.URL.createObjectURL(blob)
  a.download = name
  event = document.createEvent("MouseEvents")
  event.initMouseEvent "click"
  a.dispatchEvent event
  true

#compliation class
class Compilation

  constructor: ->
    #compilation wide values
    @values = {}
    @events = {}
    @dones = []
    @pending = 0

  #private api

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
    console.warn 'compile.js', str

  _err: (str) ->
    console.error 'compile.js', str
    @_emit 'error', str

  _ajax: (url, callback) ->
    #jquery version though could be swapped out...
    m = url.match /https?:\/\/[^\/]+/
    # return @_err "ajax: Invalid URL: #{url}" unless m

    if not m or m[0] is window.location.origin
      $.ajax({url}).always (body, status, msg) =>
        return @_err "ajax: #{msg}" if status is 'error'
        callback body
    else
      $.ajax({
        url: 'http://compilejs.jpillora.com/retrieve',
        data: {url}
        dataType: 'jsonp'
      }).always (obj, status, msg) =>
        return @_err "ajax: #{msg}" if status is 'error'
        return @_err "ajax: #{obj.error}" if obj.error
        callback obj.body

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
      return @
    if typeof name isnt 'string'
      @_err

    doCallback = ->
      @_emit "get:#{name}"
      callback @values[name]
      @_end()

    if @values[name]
      setTimeout doCallback, 0
    else
      @_on "set:#{name}", doCallback

    @

  set: (name, str) ->
    @_begin()

    if @values[name]
      return @_err "set: '#{name}' already exists"

    doCallback = (val) =>
      @values[name] = val
      @_emit "set:#{name}"
      @_end()

    #if spaces or curlys then is code string
    if /[\s\{\}]/.test str
      setTimeout (-> doCallback str), 0
    else
      @_ajax str, doCallback

    @

  download: (name) ->

    @get name, (val) =>
      return if saveAs("#{name}.js",val)
      $("<form method='post'></form>")
        .attr('action', "http://compilejs.jpillora.com/download?filename=#{encodeURIComponent(name)}.js")
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

  error: (callback) ->
    @_on 'error', callback
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
