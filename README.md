Compile.js
=========

### Summary

Compile.js is a GruntJS inspired JavaScript build tool for the browser.
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

Use the [Compile.js API Explorer](http://jpillora.com/compilejs/builder/index.html) to compile your own build of Compile.js (very meta)

### Usage

Minify your library with [UglifyJS2](https://github.com/mishoo/UglifyJS2)

``` javascript
$.compile
  .fetch('lib', 'js/my-lib.js')
  .run('uglify', {
    src: 'lib',
    dest: 'lib-min'
  })
  .download('lib-min');
```

### Demos

* [Minify example](http://jpillora.com/compilejs/example/uglify.html)
* [Download example](http://jpillora.com/compilejs/example/download.html)
* [CoffeeScript example](http://jpillora.com/compilejs/example/coffee.html)
* [Concatenate example](http://jpillora.com/compilejs/example/concat.html)
* [Popup example](http://jpillora.com/compilejs/example/popup.html)

### API

*Note: You can play with this API using the [Compile.js API Explorer](http://jpillora.com/compilejs/builder/index.html)*

#### `$.compile`.`get( name[s], callback( err, value[s] ) )`

Get a value

* `name[s]` - string or an array of strings

* `value[s]` - same type as `name[s]`

#### `$.compile`.`set( name, value )`

Set a value.

* `name` - string
* `value` - string

#### `$.compile`.`fetch( name, url )`

Fetches a URL and 

* `name` - string
* `url` - string

*Note: `url` will be retrieved with an XHR request if it has the same origin as the current page, otherwise it will be retrieved using the Compile.js JSONP proxy server*

#### `$.compile`.`run( taskName, taskConfig )`

Runs the given task with the given config

* `taskName` - string
* `taskConfig` - object

#### `$.compile`.`download( name )`

Downloads the value of `name` as `filename`

* `name` - string
* `filename` - string [optional] - defaults to "`name`.js"

*Note: On browsers that do not support [anchor download attribute](http://caniuse.com/download), the download
will be forced by POSTing the contents of the file to the Compile.js POST replay server which
will just return the content though with the `Content-Disposition` header set.*

#### `$.compile`.`popup( name )`

Open a small popup with the value of `name`

* `name` - string

*Warning: This will likely trigger a popup warning from most modern browsers*

#### `$.compile`.`log( callback ( string ) )`
#### `$.compile`.`error( callback ( string ) )`
#### `$.compile`.`warn( callback ( string ) )`

Log, Error and Warning handlers

### Tasks

#### `$.compile`.`task( taskName, definition )`

Adds a new task

If `definition` is:

* a string, it will be treated as a script URL and attempt to load it.
* a function, it must have the signature `function(config, callback)`
  * `config` will contain the object the user provides
      * `config.src` *Note: the `src` property will be passed through `instance`.`get()` and
         when this function is executed, `config.src` will be the the `value[s]`
         associated with the `name[s]`*
  * `callback` must be called when the task is complete

* If `definition` is a object, it must contain a:
  * `run` function - which matches the signature above

  and optional:

  * `fetch` object - which map global names to URLs, missing globals will be fetched. *Useful for lazy loading dependancies.*
  * `init` function - which will run once all URLs have been fetched.

#### [Task list](https://github.com/jpillora/compilejs/tree/gh-pages/dist/tasks)

* Concat - [Built-in](https://github.com/jpillora/compilejs/blob/gh-pages/src/compile.coffee#L236)
* CoffeeScript - [compile.coffee-script.js](https://github.com/jpillora/compilejs/tree/gh-pages/dist/tasks/compile.coffee-script.js)
* Uglify - [compile.uglify.js](https://github.com/jpillora/compilejs/tree/gh-pages/dist/tasks/compile.coffee-script.js)
* *More to come...*

Using the [Compile.js API Explorer](http://jpillora.com/compilejs/builder/index.html), you can build a custom version of Compile.js which includes a subset of these tasks.

#### Conceptual Overview

This library uses method chaining. There is no "create" method because a static verions of each chainable method is made which adds an extra step - creates an instance - then the corresponding instance method is called (Code is [here](https://github.com/jpillora/compilejs/blob/gh-pages/src/compile.coffee#L242)). Each instance has an event emitter. When you `get()`, an event listener will watch for the `name` to be set. When you `set()`, an event will be fired - triggering all listeners. This way, the order of operations will work itself out.

#### MIT License

Copyright © 2013 Jaime Pillora &lt;dev@jpillora.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
