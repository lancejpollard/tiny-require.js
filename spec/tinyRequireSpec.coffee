describe "require", ->
  it "should load library", ->
    #for name, bundle of Metro.assets.javascripts
    #  for path in bundle
    #

    require.define "underscore", (require, module, exports, __dirname, __filename) ->
      module.exports = _

    require.define "backbone", (require, module, exports, __dirname, __filename) ->
      module.exports = Backbone

    require.define "mustache", (require, module, exports, __dirname, __filename) ->
      module.exports = $ml.Renderer

    require.define "shifter/package.json", (require, module, exports, __dirname, __filename) ->
      module.exports = {"main": "lib/shifter.js"}

    require.define "shifter/lib/shifter.js", (require, module, exports, __dirname, __filename) ->
      module.exports = ->
        console.log "PACKAGE!"
        require("./example")()

    require.define "shifter/lib/example/index.js", (require, module, exports, __dirname, __filename) ->
      module.exports = ->
        console.log "EXAMP"

    require.define "shift", (require, module, exports, __dirname, __filename) ->
      class Shift
        #Stylus:               require('./shift/stylus')
        #Jade:                 require('./shift/jade')
        #Haml:                 require('./shift/haml')
        #Ejs:                  require('./shift/ejs')
        #CoffeeScript:         require('./shift/coffee_script')
        #Less:                 require('./shift/less')
        Mustache:             require('shift/shift/mustache')
        #Markdown:             require('./shift/markdown')
        #Sprite:               require('./shift/sprite')
        #YuiCompressor:        require('./shift/yui_compressor')
        #UglifyJS:             require('./shift/uglifyjs')

        engine: (extension) ->
          extension = extension.replace(/^\./, '')

          @engines[extension] ||= switch extension
            when "styl", "stylus"
              new Shift.Stylus
            when "jade"
              new Shift.Jade
            when "haml"
              new Shift.Haml
            when "ejs"
              new Shift.Ejs
            when "coffee", "coffeescript", "coffee-script"
              new Shift.CoffeeScript
            when "less"
              new Shift.Less
            when "mu", "mustache"
              new Shift.Mustache
            when "md", "mkd", "markdown", "mdown"
              new Shift.Markdown

        engines: {}

        # Pass in path, it computes the extensions and what engine you'll want
        enginesFor: (path) ->
          engines     = []
          extensions  = path.split("/")
          extensions  = extensions[extensions.length - 1]
          extensions  = extensions.split(".")[1..-1]

          for extension in extensions
            engine    = Shift.engine(extension)
            engines.push engine if engine

          engines

        render: (options, callback) ->
          self        = @
          path        = options.path
          string      = options.string  || require('fs').readFileSync(path, 'utf-8')
          engines     = options.engines || @enginesFor(path)

          iterate = (engine, next) ->
            engine.render string, options, (error, output) ->
              if error
                next(error)
              else
                string = output
                next()

          require('async').forEachSeries engines, iterate, (error) ->
            callback.call(self, error, string)

      module.exports = new Shift

    require.define "shift/shift/mustache", (require, module, exports, __dirname, __filename) ->
      class Mustache
        engine: -> @_engine ||= new (require('mustache'))

        render: (content, options, callback) ->
          if typeof(options) == "function"
            callback    = options
            options     = {}
          options     ||= {}
          path          = options.path
          error         = null

          preprocessor  = options.preprocessor || @constructor.preprocessor
          content       = preprocessor.call(@, content, options) if preprocessor

          try
            result      = @engine().to_html content, options.locals
          catch e
            error       = e
            result      = null
            error.message += ", #{path}" if path

          callback.call(@, error, result) if callback

          result

      module.exports = Mustache


    console.log require("mustache")
    console.log require("shift")