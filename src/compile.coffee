
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

#download proxy target
iframeName = guid()+guid()
$ -> $("<iframe name='#{iframeName}'></iframe>").hide().appendTo("body")

class EventEmitter
  constructor: (@parent = window)->
    @events = {}

  on: (event, callback) ->
    unless @events[event]
      @events[event] = []
    @events[event].push callback
    @parent

  emit: ->
    args = Array::slice.call arguments
    event = args.shift()
    callbacks = @events[event]
    return unless callbacks
    for callback in callbacks
      callback.apply @parent, args
    @parent

#compliation class
class Compilation

  constructor: ->
    #compilation wide values
    # @id = guid()
    @values = {}

    #compilation wide event emitter
    @_ee = new EventEmitter @

  _ajax: (url, callback) ->
    #jquery version though could be swapped out...
    m = url.match /https?:\/\/[^\/]+/
    # return @_error "ajax: Invalid URL: #{url}" unless m

    if not m or m[0] is window.location.origin
      $.ajax({url, dataType:'text'}).always (body, status, msg) =>
        return @_error "ajax: #{msg}" if status is 'error'
        callback body
    else
      @_log "jsonp request for: #{url}"
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
    , 8*1000

    doCallback = =>
      @_ee.emit "get:value:#{name}"
      clearTimeout timeout
      callback @values[name]

    if @values[name]
      setTimeout doCallback, 0
    else
      @_ee.on "set:value:#{name}", doCallback

    @

  set: (name, str, isRaw) ->
    @_log "set #{name}"
    if @values[name]
      return @_error "set: '#{name}' already exists"

    doCallback = (val) =>
      @values[name] = val
      @_ee.emit "set:value:#{name}"

    isRaw = /\s/.test(str) or not str if isRaw is `void 0`

    #if spaces or curlys then is code string
    if isRaw
      setTimeout (-> doCallback str), 0
    else
      @_ajax str, doCallback

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

      setTimeout form.remove, 1000

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
  Compilation::['_'+fn] = (str) ->
    cons[fn] str; @_ee.emit fn, str; @

#library wide tasks
tasks = {}

#public api
compile =
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
        'get', 'set', 'download',
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



#publicise
@compile = compile
