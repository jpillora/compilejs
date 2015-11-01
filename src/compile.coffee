
#native JSON fallback to jQuery
parseJSON = JSON?.parse or $.parseJSON

#helpers
isArray = (obj) ->
  Object::toString.call(obj) is '[object Array]'

guid = ->
  (Math.random()*Math.pow(2,32)).toString 16

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

encode = (str) ->
  encode.elem = encode.elem or $("<div/>")
  encode.elem.text(str).html()

#ie8 polyfill
unless Array::indexOf
  Array::indexOf or= (item) ->
    for x, i in this
      return i if x is item
    -1

#download proxy target
iframeName = 'compilejs-'+guid()+guid()
$ -> $("<iframe name='#{iframeName}'></iframe>").hide().appendTo("body")

class EventEmitter
  constructor: (@parent = window)->
    @events = {}

  on: (event, callback) ->
    unless @events[event]
      @events[event] = []
    @events[event].push callback
    @parent

  once: (event, callback) ->
    proxy = =>
      i = @events[event].indexOf proxy
      @events[event].splice 1, i
      callback.apply @parent, arguments
    @on event, proxy

  emit: ->
    args = Array::slice.call arguments
    event = args.shift()
    callbacks = @events[event]
    return unless callbacks
    for callback in callbacks
      callback.apply @parent, args
    @parent

#cross domain ajax helper
ajax = (url, callback) ->
  #jquery version though could be swapped out...
  m = url.match /https?:\/\/[^\/]+/
  # return @_error "ajax: Invalid URL: #{url}" unless m

  if not m or m[0] is window.location.origin
    $.ajax({url, dataType:'text'}).always (body, status, msg) =>
      return callback "ajax: #{msg}" if status is 'error'
      callback null, body
  else
    $.ajax({
      url: 'http://compilejs.jpillora.com/retrieve',
      data: {url}
      dataType: 'jsonp'
    }).always (obj, status, msg) =>
      return callback "ajax: #{msg}" if status is 'error'
      return callback "ajax: #{obj.error}" if obj.error
      callback null, obj.body

#compliation class
class Compilation

  constructor: ->
    #compilation wide values
    @values = {}
    #compilation wide event emitter
    @_ee = new EventEmitter @

  _getAll: (names, callback) ->
    got = 0
    values = []
    $.each names, (i, name) =>
      @get name, (val) =>
        values[i] = val
        if ++got is names.length
          callback values
    @

  #public api
  get: (name, callback) ->

    if isArray name
      return @_getAll name, callback
    if typeof name isnt 'string'
      return @_error "get: name should be a string"

    timeout = setTimeout =>
      @_warn "get: timeout waiting for '#{name}'"
    , 15*1000

    doCallback = =>
      @_ee.emit "get:value:#{name}"
      clearTimeout timeout
      callback @values[name]

    @_log "get #{name}"
    if @values[name]
      doCallback()
    else
      @_ee.once "set:value:#{name}", doCallback
    @


  set: (name, str) ->
    @_log "set #{name}"
    if @values[name]
      return @_error "set: '#{name}' already exists"
    setTimeout =>
      @values[name] = str
      @_ee.emit "set:value:#{name}"
    , 0
    @

  fetch: (name, url) ->
    @_log "fetch #{name}"
    if @values[name]
      return @_error "set: '#{name}' already exists"
    ajax url, (err, result) =>
      return @_error err if err
      @values[name] = result
      @_ee.emit "set:value:#{name}"
    @

  download: (name, filename = "#{name}.js") ->
    @_log "downloading #{name}"
    @get name, (val) =>
      if saveAs(filename,val)
        @_log "native download"
        return
      form = $("<form method='post' target='#{iframeName}'></form>")
        .hide()
        .attr('action', "http://compilejs.jpillora.com/download?filename=#{encodeURIComponent(filename)}")
        .append($("<textarea name='__compilejsDownload'></textarea>").text(val))
        .appendTo("body")
        .submit()
      @_log "replay download"
    @

  popup: (name) ->
    @get name, (val) =>
      w = window.open null,'id','width=400,height=100,toolbar=0,menubar=0,location=0,status=0,scrollbars=1,resizable=0,left=0,top=0'
      w.document.writeln "<pre>" + encode(val) + "</pre>"
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

    gotScripts = =>
      if config.src
        @_log "task: #{name}: src:", config.src
        @get config.src, gotSrc
      else
        gotSrc()

    checkScripts = =>
      gotScripts() if wait is load

    #fetch
    wait = 0
    load = 0
    if $.isPlainObject task.fetch
      for name, script of task.fetch
        continue if window[name]
        wait++
        $.ajax
          url: script
          dataType: 'script'
          cache: true
          success: =>
            load++
            checkScripts()

    checkScripts()
    @

  options: ->
    throw "Not implemented"

#add public and private chainable error,warn,log functions
cons = {}
$.each ['log', 'error', 'warn'], (i, fn) ->
  cons[fn] = ->
    return if /MSIE/.test window.navigator.userAgent
    console[fn].apply console, ['Compile.js:'].concat Array::slice.call arguments
  Compilation::[fn] = (callback) ->
    @_ee.on fn, callback; @
  Compilation::['_'+fn] = ->
    args = Array::slice.call arguments
    cons[fn].apply @, args
    @_ee.emit [fn].concat args
    @

#library wide tasks
tasks = {}

#public api
compile =
  EE: EventEmitter
  ajax: ajax
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

#create static versions of public methods which start the chain
$.each ['log', 'error', 'warn',
        'get', 'set', 'download', 'fetch'
        'run', 'popup'], (i, fn) ->
  compile[fn] = ->
    inst = new Compilation
    inst[fn].apply inst, arguments

#in-built concat task
compile.task 'concat', (config, callback) ->
  val = if typeof config.src is 'string'
    config.src
  else if $.isArray config.src
    config.src.join(config.sep || '\n')
  @set config.dest, val, true

#in-built uglify task
compile.task 'uglify',
  fetch:
    UglifyJS: "//rawgit.com/jpillora/compilejs/gh-pages/vendor/uglify.min.js"
  run: (config, callback) ->
    try
      out = UglifyJS.minify config.src, config.options
    catch e
      callback "uglify: parse error: '#{e.message}' on line: #{e.line} col: #{e.col}"
      return
    @set config.dest, out, true
    callback()

#publicise
$.compile = compile
