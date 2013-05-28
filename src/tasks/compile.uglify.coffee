unless compile?.task
  alert "Include Compile.js before tasks"

#uglify lacks a browser helper to minify code 
UglifyJS.minify = (codes, options) ->
  options = UglifyJS.defaults(options or {},
    warnings: false
    mangle: {}
    compress: {}
  )
  codes = [codes]  if typeof codes is "string"

  # 1. parse
  toplevel = null
  codes.forEach (code) ->
    toplevel = UglifyJS.parse(code,
      filename: "?"
      toplevel: toplevel
    )

  # 2. compress
  if options.compress
    compress = warnings: options.warnings
    UglifyJS.merge compress, options.compress
    toplevel.figure_out_scope()
    sq = UglifyJS.Compressor(compress)
    toplevel = toplevel.transform(sq)

  # 3. mangle
  if options.mangle
    toplevel.figure_out_scope()
    toplevel.compute_char_frequency()
    toplevel.mangle_names options.mangle

  # 4. output
  stream = UglifyJS.OutputStream()
  toplevel.print stream
  stream.toString()

#warning function optional
UglifyJS.AST_Node.warn_function = (txt) ->
  console.warn txt

#task
compile.task 'uglify', (config, callback) ->

  console.log "running uglify"
  try
    out = UglifyJS.minify config.src, config
  catch e
    callback "uglify: parse error: '#{e.message}' on line: #{e.line} col: #{e.col}"
    return

  @set config.dest, out
  callback()

