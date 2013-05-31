
#native JSON fallback to jQuery
parseJSON = JSON?.parse or $.parseJSON

#helpers
isArray = (obj) ->
  Object::toString.call(obj) is '[object Array]'

#chrome a.download
saveAs = (name, text) ->
  return false unless document.createElementNS
  a = document.createElementNS("http://www.w3.org/1999/xhtml", "a")
  return false  unless "download" of a
  blob = new window.Blob([text], type: "text/plain;charset=utf8")
  a.href = window.URL.createObjectURL(blob)
  a.download = name
  event = document.createEvent "MouseEvents"
  event.initMouseEvent "click", 1, 0, window, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null
  a.dispatchEvent event
  true


#compliation class
class Compilation

  constructor: ->
    #compilation wide values
    @values = {}
    @events = {}

  #private api
  _on: (event, callback) ->
    unless @events[event]
      @events[event] = []
    @events[event].push callback
    @

  _emit: (event, val)->
    callbacks = @events[event]
    return unless callbacks
    for callback in callbacks
      callback.call @, val
    @

  _ajax: (url, callback) ->
    #jquery version though could be swapped out...
    m = url.match /https?:\/\/[^\/]+/
    # return @_error "ajax: Invalid URL: #{url}" unless m

    if not m or m[0] is window.location.origin
      $.ajax({url, dataType:'text'}).always (body, status, msg) =>
        return @_error "ajax: #{msg}" if status is 'error'
        callback body
    else
      $.ajax({
        url: 'http://compilejs.jpillora.com/retrieve',
        data: {url}
        dataType: 'jsonp'
      }).always (obj, status, msg) =>
        return @_error "ajax: #{msg}" if status is 'error'
        return @_error "ajax: #{obj.error}" if obj.error
        callback obj.body

  _getAll: (names, callback) ->
    values = []
    for name, i in names
      ((i) =>
        @get name, (val) =>
          values[i] = val
          if names.length is values.length
            callback values
      )(i)
    @

  #public api
  get: (name, callback) ->

    if isArray name
      return @_getAll name, callback
    if typeof name isnt 'string'
      return @_error "get: name should be a string"

    timeout = setTimeout =>
      @_warn "get: timeout waiting for '#{name}'"
    , 3*1000

    doCallback = =>
      @_emit "get:value:#{name}"
      clearTimeout timeout
      callback @values[name]

    if @values[name]
      setTimeout doCallback, 0
    else
      @_on "set:value:#{name}", doCallback

    @

  set: (name, str) ->

    if @values[name]
      return @_error "set: '#{name}' already exists"

    doCallback = (val) =>
      @values[name] = val
      @_emit "set:value:#{name}"

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
    @

  run: (name, config) ->

    task = tasks[name]
    return @_error "run: Missing task '#{name}'" unless task

    gotSrc = (src) =>
      config.src = src
      #initialise if needed
      if task.init and not task._initd
        task.init()
        task._initd = true

      task.run.call @, config, (err) =>
        @_error "run: #{name}: #{err}" if err

    gotScripts = =>      if config.src
        @get config.src, gotSrc
      else
        setTimeout gotSrc, 0

    checkScripts = =>
      gotScripts() if wait is load

    #fetch
    wait = 0
    load = 0
    if $.isPlainObject task.fetch
      for name, script of task.fetch
        continue if window[name]
        wait++
        $.getScript script, => load++; checkScripts()

    checkScripts()
    @

#add public and private chainable error,warn,log functions
cons = {}
$.each ['log', 'error', 'warn'], (i, fn) ->
  cons[fn] = ->
    console[fn].apply console, ['Compile.js:'].concat Array::slice.call arguments
  Compilation::[fn] = (callback) ->
    @_on fn, callback; @
  Compilation::['_'+fn] = (str) ->
    cons[fn] str; @_emit fn, str; @

#library wide tasks
tasks = {}

#public api
compile =
  init: ->
    new Compilation
  tasks: tasks
  task: (name, def) ->
    if tasks[name]
      cons.warn "task: '#{name}' already exists"
    if typeof def is "function"
      def = {run: def}
    else if not def or typeof def.run isnt "function"
      return cons.error "task: '#{name}' Missing run function"
    # cons.log "task: add '#{name}'"
    tasks[name] = def

#in-built concat task
compile.task 'concat', (config, callback) ->
  @set config.dest,
    if typeof config.src is 'string' then config.src else
    if $.isArray config.src config.src.join(config.sep || '\n') else
    null

#publicise
if typeof exports is "object"
  module.exports = compile
else if typeof define is "function" && define.amd
  define -> compile
else
  window.compile = compile
