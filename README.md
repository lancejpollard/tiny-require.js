# TinyRequire.js

> Tiny `require` library for the browser.  3.0kb minified.  1.2kb gzipped.

## Install

```
npm install tiny-require
```

## Overview

Sometimes you want to use a Node.js module in the browser but can't because of the `require` statements.  The current solution is [browserify](https://github.com/substack/node-browserify).  But it was always pretty hard to grasp, so I put together this.  It's just the bare-bones require code for the browser, allowing you to define what the browser should do when it sees statements like `require('./relativePath')` or `require('underscore')`.

All you do is create a `require.define` block with the name of the path, and put your module code inside.  This makes it so you can easily convert non-node libraries to ones that you can `require`.  Say Backbone.js was like that, then you could just do this:

``` coffeescript
require.define "backbone", (require, module, exports, __dirname, __filename) ->
  module.exports = window.Backbone

# somewhere else...

Backbone = require('backbone')
```

Same with jQuery.

``` coffeescript
require.define "jquery", (require, module, exports, __dirname, __filename) ->
  module.exports = window.jQuery
  
$ = require('jquery')
```

### Node.js Module with a `package.json`

Then you have your `node_modules`:

``` coffeescript
require.define "my-library/package.json", (require, module, exports, __dirname, __filename) ->
  module.exports = {"main": "lib/my-library.js"}
  
require.define "my-library/lib/my-library.js", (require, module, exports, __dirname, __filename) ->
  # ... the library code
```

How do you get the code in there?  You can use pathfinder.js.  Example coming soon.

### Custom modules

``` coffeescript
require.define "my-library", (require, module, exports, __dirname, __filename) ->
  module.exports = ->
    console.log "hello world"

require.define "my-library/nested-module", (require, module, exports, __dirname, __filename) ->
  # ... module code
```

### Wrapping existing libraries

``` coffeescript
require.define "backbone", (require, module, exports, __dirname, __filename) ->
  module.exports = window.Backbone
```

### Absolute paths

You can use absolute paths, but they're not treated any differently since this is for the browser.

But, this makes sense for app-level code.

``` coffeescript
require.define "/app/models/user", (require, module, exports, __dirname, __filename) ->
  # ... user code
```

## License

(The MIT License)

Copyright &copy; 2011 [Lance Pollard](http://twitter.com/viatropos) &lt;lancejpollard@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
