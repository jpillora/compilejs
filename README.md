Compile.js
=========

#### Summary

A GruntJS inspired JavaScript build tool for the browser.
Compile.js makes it easy to create front end custom build widgets for your open-source projects.

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

Minify your library with [UglifyJS2](https://github.com/mishoo/UglifyJS2)

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

*Note: A string is seen as a URL if it doesn't have any `space`, `{` or `}` characters. Yes, very crude.
URLs will be retrieved with AJAX if they're on the same origin as the script,
otherwise they will be retrieved using the Compile.js JSONP proxy server (No SLA provided :smile:)*

##### `instance`.`run( taskName, taskConfig )`

Runs the given task with the given config

##### `instance`.`download( name )`

Downloads the value of `name` as `<name>.js`

*Note: On browsers that do not support [anchor download attribute](http://caniuse.com/download), the download
will be forced by POSTing the contents of the file to the Compile.js POST replay server which
will just return the content though with the `Content-Disposition` header set.*

##### `instance`.`log( callback ( string ) )`

Log handler (defaults to pipe to `console.log`)

##### `instance`.`error( callback ( string ) )`

Error handler (defaults to pipe to `console.error`)

##### `instance`.`warn( callback ( string ) )`

Warning handler (defaults to pipe to `console.warn`)

#### Tasks

Task list in progress...


