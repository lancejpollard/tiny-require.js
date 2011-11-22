# TinyRequire.js

> Tiny `require` library for the browser.  3.0kb minified.  1.2kb gzipped.

## Install

```
npm install tiny-require
```

## Overview

### Node.js Module with a `package.json`

``` coffeescript
require.define "my-library/package.json", (require, module, exports, __dirname, __filename) ->
  module.exports = {"main": "lib/my-library.js"}
  
require.define "my-library/lib/my-library.js", (require, module, exports, __dirname, __filename) ->
  # ... the library code
```

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
