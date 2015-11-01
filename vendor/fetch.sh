#!/bin/bash
bower install uglify-js &&
browserify --standalone UglifyJS bower_components/uglify-js > uglify.js &&
./bower_components/uglify-js/bin/uglifyjs uglify.js > uglify.min.js &&
rm uglify.js &&
echo "built latest uglify for the browser"
