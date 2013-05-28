
Compile.js
=========

> A GruntJS inspired JavaScript build tool for the browser

#### Summary

Compile.js makes it easy to create custom build widgets for your open-source projects.

#### Features

* Fluent API
* HTTP GET Files Cross-domain
  * XHR for same origin
  * Compile.js JSONP proxy server for cross origin
* Trigger File Downloads
  * Chromes a.download for instant 
  * Compile.js server POST replay for download for other browsers
* Provided tasks
* Auto-parallelisation

#### Download

Use the [Compile.js Build Tool](http://jpillora.com/compilejs/builder/index.html) (made with Compile.js, very meta)

#### Usage

Minify your library with UglifyJS2

``` javascript
compile
  .init()
  .set('lib', 'js/my-lib.js')
  .run('uglify', {
    src: 'lib',
    dest: 'lib.min'
  })
  .download('lib.min');
```

#### Demos

* [Download example](http://jpillora.com/compilejs/example/download.html)
* [Minify example](http://jpillora.com/compilejs/example/uglify.html)

#### API

*Note: This API is subject to change*

##### compile.`task( name, definition )`

Creates a new task

##### compile.`init( options )`

Returns a Compile.js `instance`

##### `instance`.`get( name, callback( err, value ) )`

Get a value

##### `instance`.`set( name, raw-string|url-string )`

Set a value.

A string is counted as raw if it has a ` ` or `{` or `}`. Yes very crude.

URLs will be retrieved with AJAX if they're on the same origin as the script,
otherwise they will be retrieved using the Compile.js JSONP proxy server (No SLA provided :smile:).

##### `instance`.`run( taskName, taskConfig )`

Runs the given task with the given config

##### `instance`.`download( name )`

Downloads the value of `name` as `<name>.js`

##### `instance`.`log( callback ( string ) )`

Log handler (defaults to pipe to `console.log`)

##### `instance`.`error( callback ( string ) )`

Error handler (defaults to pipe to `console.error`)

##### `instance`.`warn( callback ( string ) )`

Warning handler (defaults to pipe to `console.warn`)

#### Tasks

Task list in progress...


