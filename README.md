Compile.js
=========

### Summary

A GruntJS inspired JavaScript build tool for the browser.
Compile.js makes it easy to create front end custom build widgets for your open-source projects.

### Features

* Fluent API
* HTTP GET Files Cross-domain
  * XHR for same origin
  * Compile.js JSONP proxy server for cross origin
* Trigger File Downloads
  * Chromes a.download for instant
  * Compile.js server POST replay for download for other browsers
* Provided tasks
* Auto-parallelisation

### Download

Use the [Compile.js Build Tool](http://jpillora.com/compilejs/builder/index.html) (made with Compile.js, very meta)

### Usage

Minify your library with [UglifyJS2](https://github.com/mishoo/UglifyJS2)

``` javascript
compile
  .set('lib', 'js/my-lib.js')
  .run('uglify', {
    src: 'lib',
    dest: 'lib.min'
  })
  .download('lib.min');
```

### Demos

* [Download example](http://jpillora.com/compilejs/example/download.html)
* [Minify example](http://jpillora.com/compilejs/example/uglify.html)

### API

*Note: This API is subject to change*

#### `compile`.`get( name[s], callback( err, value[s] ) )`

Get a value

* `name[s]` - string or an array of strings

* `value[s]` - will be the same type as `name[s]`

#### `compile`.`set( name, value )`

Set a value.

* `name` - string
* `value` - string
* `isRaw` - boolean [optional] - defaults to `value contains a space`

*Note: `value` will be seen as a URL and then fetched if
it does not contain any `space` characters.*

*Note: a URL will be retrieved with an XHR request if it is on the same origin as the current page, otherwise it will be retrieved using the Compile.js JSONP proxy server*

#### `compile`.`run( taskName, taskConfig )`

Runs the given task with the given config

* `taskName` - string
* `taskConfig` - object

#### `compile`.`download( name )`

Downloads the value of `name` as `filename`

* `name` - string
* `filename` - string [optional] - defaults to "`name`.js"

*Note: On browsers that do not support [anchor download attribute](http://caniuse.com/download), the download
will be forced by POSTing the contents of the file to the Compile.js POST replay server which
will just return the content though with the `Content-Disposition` header set.*

#### `compile`.`popup( name )`

Open a small popup with the value of `name`

* `name` - string

*Warning: This will likely trigger a popup warning from most modern browsers*

#### `compile`.`log( callback ( string ) )`

Log handler

#### `compile`.`error( callback ( string ) )`

Error handler

#### `compile`.`warn( callback ( string ) )`

Warning handler

### Tasks

#### compile.`task( taskName, definition )`

Adds a new task

If `definition` is:

* a string, it will be treated as a script URL and attempt to load it.
* a function, it must have the signature `function(config, callback)`
  * `config` will contain the object the user provides
      * `config.src` *Note: the `src` property will be passed through `instance`.`get()` and
         when this function is executed, `config.src` will be the the `value[s]`
         associated with the `name[s]`*
  * `callback` must be called when the task is complete

* If `definition` is a object, it must contain:
  * a required `run` function - which matches the signature above.
  * an optional `fetch` object - which map global names to URLs, missing globals will be fetched.
  * an optional `init` function - which will run once all URLs have been fetched.

#### (Task list)[https://github.com/jpillora/compilejs/tree/gh-pages/dist/tasks]

* Concat - [Built-in](https://github.com/jpillora/compilejs/blob/gh-pages/src/compile.coffee#L236)
* CoffeeScript - [compile.coffee-script.js](https://github.com/jpillora/compilejs/tree/gh-pages/dist/tasks/compile.coffee-script.js)
* Uglify - [compile.uglify.js](https://github.com/jpillora/compilejs/tree/gh-pages/dist/tasks/compile.coffee-script.js)
* *More to come...*






