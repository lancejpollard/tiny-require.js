# mostly from browserify, simplified a bit
# require
window.require = (file, cwd) ->
  resolved  = require.resolve(file, cwd or "/")
  module    = require.modules[resolved]
  throw new Error("Failed to resolve module #{file}, tried #{resolved}") unless module
  if module._cached then module._cached else module()

require.paths       = []
require.modules     = {}
require.extensions  = [".js", ".coffee"]
require.cache       = {}
require._core       =
  assert: true
  events: true
  fs:     true
  path:   true
  vm:     true

require.resolve = (path, cwd) ->
  return path if require._core[path]
  #resolved = require.cache[path]
  #return resolved if resolved
  _path = require.modules.path()

  cwd ||= "."
  
  if path.match(/^(?:\.\.?\/|\/)/)
    resolved = loadAsFileSync(_path.resolve(cwd, path)) || loadAsDirectorySync(_path.resolve(cwd, path), _path)

  resolved ||= loadAsModuleSync(path, _path)
  if resolved
    require.cache[path] = resolved
  else
    throw new Error("Cannot find module '#{path}'")

require.define = (filename, fn) ->
  dirname = if require._core[filename] then "" else require.modules.path().dirname(filename)
  
  require_ = (file) ->
    require file, dirname
  
  require_.resolve = (name) ->
    require.resolve name, dirname

  require_.modules = require.modules
  require_.define = require.define
  module_ = exports: {}
  require.modules[filename] = ->
    require.modules[filename]._cached = module_.exports
    fn.call module_.exports, require_, module_, module_.exports, dirname, filename
    require.modules[filename]._cached = module_.exports
    module_.exports
    
# process
process = {}  if typeof process is "undefined"
unless process.nextTick
  process.nextTick = (fn) ->
    setTimeout fn, 0
process.title = "browser"  unless process.title
unless process.binding
  process.binding = (name) ->
    if name is "evals"
      require "vm"
    else
      throw new Error("No such module")
unless process.cwd
  process.cwd = ->
    "."

# path  
require.define "path", (require, module, exports, __dirname, __filename) ->
  filter = (xs, fn) ->
    res = []
    i = 0

    while i < xs.length
      res.push xs[i]  if fn(xs[i], i, xs)
      i++
    res
    
  normalizeArray = (parts, allowAboveRoot) ->
    up = 0
    i = parts.length

    while i >= 0
      last = parts[i]
      if last is "."
        parts.splice i, 1
      else if last is ".."
        parts.splice i, 1
        up++
      else if up
        parts.splice i, 1
        up--
      i--
    if allowAboveRoot
      while up--
        parts.unshift ".."
        up
    parts
  
  splitPathRe = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/
  
  exports.resolve = ->
    resolvedPath        = ""
    resolvedAbsolute    = false
    i                   = arguments.length
    
    while i >= -1 and not resolvedAbsolute
      path              = (if (i >= 0) then arguments[i] else process.cwd())
      i--
      continue if typeof path isnt "string" or not path
      resolvedPath      = path + "/" + resolvedPath
      resolvedAbsolute  = path.charAt(0) is "/"
    
    resolvedPath = normalizeArray(filter(resolvedPath.split("/"), (p) ->
      !!p
    ), not resolvedAbsolute).join("/")
    ((if resolvedAbsolute then "/" else "") + resolvedPath) or "."
  
  exports.normalize = (path) ->
    isAbsolute    = path.charAt(0) is "/"
    trailingSlash = path.slice(-1) is "/"
    path = normalizeArray(filter(path.split("/"), (p) ->
      !!p
    ), not isAbsolute).join("/")
    path = "."  if not path and not isAbsolute
    path += "/"  if path and trailingSlash
    (if isAbsolute then "/" else "") + path

  exports.join = ->
    paths = Array::slice.call(arguments, 0)
    exports.normalize filter(paths, (p, index) ->
      p and typeof p is "string"
    ).join("/")
  
  exports.dirname = (path) ->
    dir = splitPathRe.exec(path)[1] or ""
    isWindows = false
    unless dir
      "."
    else if dir.length is 1 or (isWindows and dir.length <= 3 and dir.charAt(1) is ":")
      dir
    else
      dir.substring 0, dir.length - 1

  exports.basename = (path, ext) ->
    f = splitPathRe.exec(path)[2] or ""
    f = f.substr(0, f.length - ext.length)  if ext and f.substr(-1 * ext.length) is ext
    f

  exports.extname = (path) ->
    splitPathRe.exec(path)[3] or ""

# helpers
loadAsFileSync = (path) ->
  return path if require.modules[path]

  i = 0

  while i < require.extensions.length
    extPath = path + require.extensions[i]
    return extPath if require.modules[extPath]
    i++

  null

loadAsDirectorySync = (path, _path) ->
  resolved  = null
  path      = path.replace(/\/+$/, "")
  pkgfile   = path + "/package.json"

  if require.modules[pkgfile]
    pkg       = require.modules[pkgfile]()
    resolved  = loadAsFileSync(_path.resolve(path, pkg.main)) if pkg.main

  resolved ||= loadAsFileSync "#{path}/index"

loadAsModuleSync = (path, _path) ->
  return path if require.modules[path]

  loadAsFileSync(path, _path) || loadAsDirectorySync(path, _path)
