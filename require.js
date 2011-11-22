(function() {
  var loadAsDirectorySync, loadAsFileSync, loadAsModuleSync, process;

  window.require = function(file, cwd) {
    var module, resolved;
    resolved = require.resolve(file, cwd || "/");
    module = require.modules[resolved];
    if (!module) {
      throw new Error("Failed to resolve module " + file + ", tried " + resolved);
    }
    if (module._cached) {
      return module._cached;
    } else {
      return module();
    }
  };

  require.paths = [];

  require.modules = {};

  require.extensions = [".js", ".coffee"];

  require.cache = {};

  require._core = {
    assert: true,
    events: true,
    fs: true,
    path: true,
    vm: true
  };

  require.resolve = function(path, cwd) {
    var resolved, _path;
    if (require._core[path]) return path;
    _path = require.modules.path();
    cwd || (cwd = ".");
    if (path.match(/^(?:\.\.?\/|\/)/)) {
      resolved = loadAsFileSync(_path.resolve(cwd, path)) || loadAsDirectorySync(_path.resolve(cwd, path), _path);
    }
    resolved || (resolved = loadAsModuleSync(path, _path));
    if (resolved) {
      return require.cache[path] = resolved;
    } else {
      throw new Error("Cannot find module '" + path + "'");
    }
  };

  require.define = function(filename, fn) {
    var dirname, module_, require_;
    dirname = require._core[filename] ? "" : require.modules.path().dirname(filename);
    require_ = function(file) {
      return require(file, dirname);
    };
    require_.resolve = function(name) {
      return require.resolve(name, dirname);
    };
    require_.modules = require.modules;
    require_.define = require.define;
    module_ = {
      exports: {}
    };
    return require.modules[filename] = function() {
      require.modules[filename]._cached = module_.exports;
      fn.call(module_.exports, require_, module_, module_.exports, dirname, filename);
      require.modules[filename]._cached = module_.exports;
      return module_.exports;
    };
  };

  if (typeof process === "undefined") process = {};

  if (!process.nextTick) {
    process.nextTick = function(fn) {
      return setTimeout(fn, 0);
    };
  }

  if (!process.title) process.title = "browser";

  if (!process.binding) {
    process.binding = function(name) {
      if (name === "evals") {
        return require("vm");
      } else {
        throw new Error("No such module");
      }
    };
  }

  if (!process.cwd) {
    process.cwd = function() {
      return ".";
    };
  }

  require.define("path", function(require, module, exports, __dirname, __filename) {
    var filter, normalizeArray, splitPathRe;
    filter = function(xs, fn) {
      var i, res;
      res = [];
      i = 0;
      while (i < xs.length) {
        if (fn(xs[i], i, xs)) res.push(xs[i]);
        i++;
      }
      return res;
    };
    normalizeArray = function(parts, allowAboveRoot) {
      var i, last, up;
      up = 0;
      i = parts.length;
      while (i >= 0) {
        last = parts[i];
        if (last === ".") {
          parts.splice(i, 1);
        } else if (last === "..") {
          parts.splice(i, 1);
          up++;
        } else if (up) {
          parts.splice(i, 1);
          up--;
        }
        i--;
      }
      if (allowAboveRoot) {
        while (up--) {
          parts.unshift("..");
          up;
        }
      }
      return parts;
    };
    splitPathRe = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;
    exports.resolve = function() {
      var i, path, resolvedAbsolute, resolvedPath;
      resolvedPath = "";
      resolvedAbsolute = false;
      i = arguments.length;
      while (i >= -1 && !resolvedAbsolute) {
        path = (i >= 0 ? arguments[i] : process.cwd());
        i--;
        if (typeof path !== "string" || !path) continue;
        resolvedPath = path + "/" + resolvedPath;
        resolvedAbsolute = path.charAt(0) === "/";
      }
      resolvedPath = normalizeArray(filter(resolvedPath.split("/"), function(p) {
        return !!p;
      }), !resolvedAbsolute).join("/");
      return ((resolvedAbsolute ? "/" : "") + resolvedPath) || ".";
    };
    exports.normalize = function(path) {
      var isAbsolute, trailingSlash;
      isAbsolute = path.charAt(0) === "/";
      trailingSlash = path.slice(-1) === "/";
      path = normalizeArray(filter(path.split("/"), function(p) {
        return !!p;
      }), !isAbsolute).join("/");
      if (!path && !isAbsolute) path = ".";
      if (path && trailingSlash) path += "/";
      return (isAbsolute ? "/" : "") + path;
    };
    exports.join = function() {
      var paths;
      paths = Array.prototype.slice.call(arguments, 0);
      return exports.normalize(filter(paths, function(p, index) {
        return p && typeof p === "string";
      }).join("/"));
    };
    exports.dirname = function(path) {
      var dir, isWindows;
      dir = splitPathRe.exec(path)[1] || "";
      isWindows = false;
      if (!dir) {
        return ".";
      } else if (dir.length === 1 || (isWindows && dir.length <= 3 && dir.charAt(1) === ":")) {
        return dir;
      } else {
        return dir.substring(0, dir.length - 1);
      }
    };
    exports.basename = function(path, ext) {
      var f;
      f = splitPathRe.exec(path)[2] || "";
      if (ext && f.substr(-1 * ext.length) === ext) {
        f = f.substr(0, f.length - ext.length);
      }
      return f;
    };
    return exports.extname = function(path) {
      return splitPathRe.exec(path)[3] || "";
    };
  });

  loadAsFileSync = function(path) {
    var extPath, i;
    if (require.modules[path]) return path;
    i = 0;
    while (i < require.extensions.length) {
      extPath = path + require.extensions[i];
      if (require.modules[extPath]) return extPath;
      i++;
    }
    return null;
  };

  loadAsDirectorySync = function(path, _path) {
    var pkg, pkgfile, resolved;
    resolved = null;
    path = path.replace(/\/+$/, "");
    pkgfile = path + "/package.json";
    if (require.modules[pkgfile]) {
      pkg = require.modules[pkgfile]();
      if (pkg.main) resolved = loadAsFileSync(_path.resolve(path, pkg.main));
    }
    return resolved || (resolved = loadAsFileSync("" + path + "/index"));
  };

  loadAsModuleSync = function(path, _path) {
    if (require.modules[path]) return path;
    return loadAsFileSync(path, _path) || loadAsDirectorySync(path, _path);
  };

})();
