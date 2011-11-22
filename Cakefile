{exec, spawn} = require 'child_process'
sys           = require 'util'
shift         = require 'shift'
fs            = require 'fs'
gzip          = require 'gzip'

task 'spec', 'Run jasmine specs', ->
  spec = spawn './node_modules/jasmine-node/bin/jasmine-node', ['--coffee', './spec']
  spec.stdout.on 'data', (data) ->
    data = data.toString().replace(/^\s*|\s*$/g, '')
    if data.match(/\u001b\[3\dm[\.F]\u001b\[0m/)
      sys.print data
    else
      data = "\n#{data}" if data.match(/Finished/)
      console.log data
  spec.stderr.on 'data', (data) -> console.log data.toString().trim()
  
task 'coffee', 'Auto compile src/**/*.coffee files into lib/**/*.js', ->
  coffee = spawn './node_modules/coffee-script/bin/coffee', ['-o', '.', '-w', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'build', ->
  engine = new shift.UglifyJS
  
  engine.render fs.readFileSync("require.js", "utf-8"), (error, result) ->
    throw error if error
    
    fs.writeFileSync("require.min.js", result)
    minified = (fs.statSync("require.min.js").size / 1000).toFixed(1)
    
    gzip result, (error, output) ->
      fs.writeFileSync("require.min.js.gz", output)
      gzipped = (fs.statSync("require.min.js.gz").size / 1000).toFixed(1)
      fs.unlinkSync("require.min.js.gz")
      
      readme = fs.readFileSync("README.md", "utf-8")
        .replace(/[\d\.]+kb minified/, "#{minified}kb minified")
        .replace(/[\d\.]+kb gzipped/, "#{gzipped}kb gzipped")
        
      fs.writeFileSync("README.md", readme)
      
      console.log "#{minified}kb minified. #{gzipped}kb gzipped."