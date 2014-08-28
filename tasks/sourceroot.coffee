
module.exports = (grunt) ->
  path  = require 'path'
  _     = require 'underscore'
  chalk = require 'chalk'

  grunt.registerMultiTask 'sourceroot', (target) ->

    options = this.options
      sourceroot : 'app'

    sourceroot = new RegExp "^#{options.sourceroot}"

    this.files.forEach (file) ->

      files = grunt.file.expand file.src

      maps = _(files).chain()

        # Load sourcemap JSON and resolve src + dest locations.
        .map (dest) ->
          _.extend(
            (src:  dest)
            (dest: dest.replace(file.src, file.dest))
            (grunt.file.readJSON(dest + '.map'))
            (file: path.basename(dest))
          )

        # Remove sourceroot from the sources URLs.
        .map (sourcemap) ->
          _(sourcemap).tap ({sources}) ->
            for s,i in sources
              sources[i] = s.replace(sourceroot, '')

        # Write the modified sourcemap and copy the css file.
        .map (sourcemap) ->
          grunt.file.copy(sourcemap.src, sourcemap.dest)
          grunt.log.writeln("<- #{chalk.cyan(sourcemap.src)}")
          grunt.log.writeln("-> #{chalk.green(sourcemap.dest)}")

          grunt.file.write(sourcemap.dest + '.map', JSON.stringify(sourcemap))
          grunt.log.writeln("<- #{chalk.cyan("#{sourcemap.src}.map")}")
          grunt.log.writeln("-> #{chalk.green("#{sourcemap.dest}.map")}")

          grunt.log.writeln('')

        # This is unnecessary; just to be consistent.
        .value()

