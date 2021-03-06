'use strict';

module.exports = (grunt) ->
	# Measures the time Grunt plugins took to execute.
	require('time-grunt')(grunt);

	# Initialises all Grunt plugins.
	require('load-grunt-tasks')(grunt);

	# Application configuration.
	config =
	# Some tasks change their configuration depending on the
	# state of the debug environment. Don't change the variable, though.
	# Use `grunt task --debug`.
		debug: false

	# The App's source files.
		app: 'app'

	# The build's destination catalogue.
		dist: 'dist'

	# The catalogue where Bower libraries are downloaded into.
		components: 'bower_components'

	# Hostname of the development environment.
		hostname: 'localhost'

	# Port used to serve application in a browser.
		port: 9000

	# Livereload's port
		livereloadPort: 35729

	# Hostname of the server.
		remoteHostname: 'localhost'

	# Port used to allow a remote connection to the app's
	# local server made by the connect:local task.
		remotePort: 9001

	grunt.initConfig
	# Import the configuration.
		config: config

	# Get the app's information.
		pkg: grunt.file.readJSON 'package.json'

	# Documentation: https://github.com/gruntjs/grunt-contrib-watch
		watch:
		# The watch task will be reloaded on the Gruntfile's change.
			gruntfile:
				files: ['Gruntfile.js']

			js:
				files: ['<%= config.app %>/scripts/{,*/}*.js']
				options:
					livereload: true

			jade:
				files: ['<%= config.app %>{,*/}*.jade']
				tasks: ['newer:jade:development']

			coffee:
				files: ['<%= config.app %>/scripts/{,*/}*.coffee']
				tasks: ['newer:coffee:development']

			styles:
				files: ['<%= config.app %>/styles/{,*/}*.css']
				tasks: ['newer:copy:styles', 'newer:autoprefixer']

			less:
				files: ['<%= config.app %>/styles/{,*/}*.less'],
				tasks: ['less:development', 'newer:autoprefixer']

			sass:
				files: ['<%= config.app %>/styles/{,*/}*.{sass,scss}']
				tasks: ['sass:development', 'newer:autoprefixer']

		# Livereload's options and paths to files that don't require
		# running special tasks, or are the outcome of those tasks.
			livereload:
				options:
					livereload: '<%= config.livereloadPort %>'

				files: [
					'<%= config.app %>/{,*/}*.html'
					'<%= config.app %>/images/{,*/}*'
					'.tmp/{,*/}*.html'
					'.tmp/styles/{,*/}*.css'
					'.tmp/scripts/{,*/}*.js'
				]

	# Documentation: https://github.com/gruntjs/grunt-contrib-connect
		connect:
		# Basic connection options.
			options:
				port: '<%= config.port %>'
				livereload: '<%= config.livereloadPort %>'

			# Open a browser.
				open: false

			# By default make the app visible only on the computer.
				hostname: '<%= config.hostname %>'

		# Starts a development server.
			development:
				options:
				# Defines the paths that will be used by the server.
					middleware: (connect) ->
						return [
							connect.static('.tmp')
							connect().use '/bower_components', connect.static('./bower_components')
							connect.static('./bower_components/requirejs')
							connect.static(config.app)
						]

		# Starts a local server with a distribution version of the app.
			server:
				options:
					base: '<%= config.dist %>'
					livereload: false

				# Makes it visible from the outside
					hostname: '<%= config.remoteHostname %>'
					port: '<%= config.remotePort %>'

	# Documentation: https://github.com/gruntjs/grunt-contrib-clean
		clean:
		# Clean the .tmp catalogue and the distribution's target catalogue.
			distribution:
				files: [
					{
						dot: true
						src: [
							'.tmp'
							'<%= config.dist %>/*'
							'!<%= config.dist %>/.git*'
						]
					}
				]

		# Just clean the .tmp catalogue.
			server: '.tmp'

	# Documentation: https://github.com/gruntjs/grunt-contrib-copy
		copy:
		# Copy files not processed in any other task.
			distribution:
				files: [
					{
						expand: true,
						dot: true,
						cwd: '<%= config.app %>',
						dest: '<%= config.dist %>',
						src: [
							'{,*/}*.html',
							'*.{ico,png,txt,md}', # Favicons and text files
							'images/{,*/}*.webp', # .webp is not minified by the imagemin.
							'fonts/{,*/}*.*',
							'assets/{,*/}*.*' # Additional assets the project migh have (like PDFs)
						]
					}
					{

					# Compiled HTMLs
						expand: true
						dot: true
						cwd: '.tmp'
						dest: '<%= config.dist %>'
						src: [ '{,*/}*.html' ]
					}
					{
					# Apache configuration from the apache-server-configs module.
						src: 'node_modules/apache-server-configs/dist/.htaccess'
						dest: '<%= config.dist %>/.htaccess'
					}
				]

		# Copy .css files to the temp directory, so they can be later processed.
			styles:
				expand: true
				dot: true
				cwd: '<%= config.app %>/styles'
				dest: '.tmp/styles/'
				src: '{,*/}*.css'

		# Copy .js files to the temp directory, so they can be later processed.
			scripts:
				expand: true
				dot: true
				cwd: '<%= config.app %>/scripts'
				dest: '.tmp/scripts'
				src: '{,*/}*.js'

		# Copy the concatenated styles when the cssmin task is not used.
			concatStyles:
				expand: true
				dot: true
				cwd: '.tmp/concat'
				src: 'styles/*.css'
				dest: '<%= config.dist %>'

	# Documentation: https://github.com/gruntjs/grunt-contrib-less
		less:
			options:
				paths: ['<%= config.app %>/styles', 'bower_components']

			development:
				options:
					sourceMap: true
					sourceMapFilename: '.tmp/styles/less.css.map'

				files:
					'.tmp/styles/less.css': '<%= config.app %>/styles/index.less'

			distribution:
				files:
					'.tmp/styles/less.css': '<%= config.app %>/styles/index.less'

	# Documentation: https://github.com/gruntjs/grunt-contrib-sass
		sass:
			options:
				sourcemap: true
				loadPath: 'bower_components'

			development:
				files: [
					{
						expand: true,
						cwd: '<%= config.app %>/styles'
						src: ['*.{scss,sass}']
						dest: '.tmp/styles'
						ext: '.css'
					}
				]

			distribution:
				files: [
					{
						expand: true
						cwd: '<%= config.app %>/styles'
						src: ['*.{scss,sass}']
						dest: '.tmp/styles'
						ext: '.css'
					}
				]

	# Documentation: https://github.com/nDmitry/grunt-autoprefixer
		autoprefixer:
			options:
				browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1']

		# The plugin requires a target.
			distribution:
				files: [
					{
						expand: true
						dot: true
						cwd: '.tmp/styles/'
						src: '{,*/}*.css'
						dest: '.tmp/styles/'
					}
				]

	# Documentation: https://github.com/gruntjs/grunt-contrib-coffee
		coffee:
			options:
				bare: true

			distribution:
				files: [
					{
						expand: true
						cwd: '<%= config.app %>/scripts'
						src: '{,*/}*.coffee'
						dest: '.tmp/scripts'
						ext: '.js'
					}
				]

			development:
				options:
					sourceMap: true

				files: [
					{
						expand: true
						cwd: '<%= config.app %>/scripts'
						src: '{,*/}*.coffee'
						dest: '.tmp/scripts'
						ext: '.js'
					}
				]

	# Documentation: https://github.com/cbas/grunt-rev
		rev:
			distribution:
				files:
					src: [
						'<%= config.dist %>/scripts/{,*/}*.js',
						'<%= config.dist %>/styles/{,*/}*.css',
						'<%= config.dist %>/images/{,*/}*.*',
						'<%= config.dist %>/styles/fonts/{,*/}*.*',
						'<%= config.dist %>/*.{ico,png}'
					]

	# Reads the HTML for usemin blocks to enable smart builds that automatically
	# concat, minify and revision files. Creates configurations in memory so
	# additional tasks can operate on them
	# Documentation: https://github.com/yeoman/grunt-usemin
		useminPrepare:
			options:
				dest: '<%= config.dist %>'

			html:
				files:
					src: ['<%= config.app %>/index.html', '.tmp/index.html']

	# Performs rewrites based on the rev and the useminPrepare configuration
	# Documentation: https://github.com/yeoman/grunt-usemin
		usemin:
			options:
				assetsDirs: ['<%= config.dist %>', '<%= config.dist %>/images']
				patterns:
				# Rename references in JavaScript files.
				# Solution: https://github.com/yeoman/grunt-usemin/issues/235
					js: [
						[/(images\/.*?\.(?:gif|jpeg|jpg|png|webp|svg))/gm, 'Update the JS to reference our revved images']
					]

			html: ['<%= config.dist %>/{,*/}*.html']
			css: ['<%= config.dist %>/styles/{,*/}*.css']
			js: ['<%= config.dist %>/scripts/{,*/}*.js']


	# The concat, uglify and cssmin tasks' options are defined automatically by the usemin
	# task. If you want to add a custom behaviour, read the usemin's docs.

	# Documentation: https://github.com/gruntjs/grunt-contrib-concat
	# concat:
	# Settings for the task are provided by the usemin task.
	# The task moves concatenated files into the dist catalogue
	# so the usemin can then rev them and apply other necessary actions.

	# Documentation: https://github.com/gruntjs/grunt-contrib-cssmin
		cssmin:
		# Only the global options. The files are managed by the usemin task.
			options:
				report: 'gzip'
				banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %> */'

	# Documentation: https://github.com/gruntjs/grunt-contrib-uglify
		uglify:
			options:
				compress:
				# Set a value for some variables.
					global_defs:
						'DEBUG': false

					dead_code: true
					drop_console: true

				preserveComments: 'some'
				report: 'gzip'
				banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %> */\n'

			debug:
				options:
					mangle: false
					compress: false
					sourceMap: true
					beautify: true
					banner: '/*! <%= pkg.name %> - v<%= pkg.version %>-debug - <%= grunt.template.today("yyyy-mm-dd") %> */\n'

			# Minify and place the require.js library in the destination folder.
			requirejs:
				files:
					'<%= config.dist %>/require.js': ['bower_components/requirejs/require.js']

	# Documentation: https://github.com/gruntjs/grunt-contrib-requirejs
		requirejs:
			distribution:
				options:
					optimize: 'none'
					mainConfigFile: '<%= config.app %>/scripts/req-main.js'
					name: 'req-main'
					out: '<%= config.dist %>/scripts/req-main.js'

	# Documentation: https://github.com/gruntjs/grunt-contrib-imagemin
		imagemin:
			distribution:
				files: [
					{
						expand: true
						cwd: '<%= config.app %>/images'
						src: '{,*/}*.{gif,jpeg,jpg,png}'
						dest: '<%= config.dist %>/images'
					}
				]

	# Documentation: https://github.com/sindresorhus/grunt-svgmin
		svgmin:
			distribution:
				files: [
					{
						expand: true
						cwd: '<%= config.app %>/images'
						src: '{,*/}*.svg'
						dest: '<%= config.dist %>/images'
					}
				]

	# Documentation: https://github.com/gruntjs/grunt-contrib-jade
		jade:
			options:
				pretty: true # htmlmin deals with the minification.

			development:
				options:
					data:
						DEBUG: true

				files: [
					{
						expand: true,
						cwd: '<%= config.app %>'
						src: '{,*/}*.jade'
						dest: '.tmp'
						ext: '.html'
					}
				]

			distribution:
				options:
					data:
						DEBUG: false

				files: [
					{
						expand: true,
						cwd: '<%= config.app %>',
						src: '{,*/}*.jade',
						dest: '.tmp',
						ext: '.html'
					}
				]

	# Documentation: https://github.com/gruntjs/grunt-contrib-htmlmin
		htmlmin:
			options:
				removeComments: true,
				removeCommentsFromCDATA: true,
				useShortDoctype: true,
				collapseBooleanAttributes: true,
				removeRedundantAttributes: true,
				removeScriptTypeAttributes: true,
				removeStyleLinkTypeAttributes: true,
				removeAttributeQuotes: true,
				removeEmptyAttributes: true,
				removeOptionalTags: true

			distribution:
				options:
					collapseWhitespace: true,
					conservativeCollapse: true,
					minifyJS: true,
					minifyCSS: true

				files: [
					{
						expand: true
						cwd: '<%= config.dist %>'
						src: '{,*/}*.html'
						dest: '<%= config.dist %>'
					}
				]

			debug:
				files: [
					{
						expand: true
						cwd: '<%= config.dist %>'
						src: '{,*/}*.html'
						dest: '<%= config.dist %>'
					}
				]


	# Documentation: https://github.com/sindresorhus/grunt-concurrent
		concurrent:
			development: [
				# Compile the jade files.
				'jade:development'

				# Copy styles, so they can be autoprefixed.
				'copy:styles'

				# Compile the development version of less files.
				'less:development'

				# Compile the development version of sass files.
				'sass:development'

				# Compile the development version of coffee files.
				'coffee:development'
			]
			distribution: [
				# Images minification.
				'imagemin'
				'svgmin'

				# Styles coompilation and related tasks.
				'copy:styles'
				'less:distribution'
				'sass:distribution'

				# Scripts compilation and related tasks.
				'copy:scripts'
				'coffee:distribution'
			]

		compress:
			options:
				archive: 'archive/' +
					'<%= pkg.name %>_' +
					'v<%= pkg.version %>_' +
					'<%= grunt.template.today("yyyy-mm-dd") %>' +
					'.zip'

			files:
				expand: true
				dot: true
				cwd: '<%= config.dist %>'
				src: '**'
				dest: ''

	# Supporting task that renames arhive files adding the md4 check sum. Shouldn't be
	# used alone.
	grunt.registerTask '_rename-archive', 'Adds the md5 checksum to the archive.', (name) ->
		fs = require 'fs'
		crypto = require 'crypto'
		md5 = crypto.createHash 'md5'
		file = grunt.template.process name
		buffer = fs.readFileSync file

		md5.update buffer

		grunt.file.copy file, file.replace '.zip', '_[' + md5.digest('hex') + '].zip'
		grunt.file.delete file

	# Archives the current build (files in the dist directory).
	grunt.registerTask 'archive', 'Creates an archive of the current build.', ->
		name = grunt.config.get 'compress.options.archive'

		if grunt.option 'debug'
			# Add the -debug to the archive name.
			name = name.replace '.zip', '-debug.zip'
			grunt.config.set 'compress.options.archive', name

		grunt.task.run 'compress'
		grunt.task.run '_rename-archive:' + name

	# Make the run task the default.
	grunt.registerTask 'default', ->
		# TODO: Rather than starting the development environment, should be used to
		# test and build the app.
		grunt.task.run 'develop'

	# The run task starts a development server.
	grunt.registerTask 'develop', 'Starts the development tasks.', (open) ->
		if grunt.option('open') or open
			grunt.config.set 'connect.options.open', true

		grunt.task.run [
			# Clean the temp catalogue.
			'clean:server'

			# Preprocessors.
			'concurrent:development'

			# Autoprefix CSS files.
			'autoprefixer'

			# Create the development server.
			'connect:development'

			# Run the watch task.
			'watch'
		]

	# Serve the built version of the application.
	grunt.registerTask 'serve', 'Serve the application.', (env) ->
		if grunt.option 'open'
			grunt.config.set 'connect.options.open', true

		grunt.task.run [ 'build' + ( if env is 'debug' then ':debug' else '' ), 'connect:server:keepalive' ]

	# Alias tasks for distribution and debug build environments.
	# TODO: the dist task should do more than just build the app.
	# Eg. add version in package.json, put the git tag, create a package
	# or upload the files on a server.
	grunt.registerTask 'dist', ['build:distribution']
	grunt.registerTask 'dist-debug', ['build:debug']

	# The build task. By default builds a release ready application.
	grunt.registerTask 'build', 'Build the app', (env) ->
		# Check for a debug request ( can be done by --debug and build:debug );
		debug = grunt.option('debug') or env is 'debug'

		# Make required changes when the debug build was requested.
		if debug
			grunt.log.writeln 'Debug build initiated.'

			# Set the global debug flag. Some tasks' configuration might
			# change depending on the value of the debug environment.
			# TIP: you can use '<% config.debug %>' ? _isDebug_ : _isProduction_
			# when configuring tasks.
			grunt.config.set 'config.debug', true

			# Set some tasks' options manually here, since they use the usemin's
			# automatic configuration, so you can't easily point them to the wanted target.
			grunt.config.set 'uglify.options', grunt.config.get 'uglify.debug.options'
		else
			grunt.log.writeln 'Executing a release-ready build.'

		grunt.task.run [
			# Clean the temp and distribution catalogues.
			'clean:distribution'

			# Compile the jade files beforehand to allow using index.jade as a main file
			# for usemin.
			'jade:distribution'

			# Make necessary preparations for other tasks.
			'useminPrepare'

			# Do some paralel tasks, such as preprocessors compilation.
			'concurrent:distribution'

			# Vendor-prefix the CSS
			'autoprefixer'

			# Combine scripts and styles to make a single file for each.
			'concat'

			# Minify the style sheet or copy the styles if in the debug mode.
			if debug then 'cssmin' else 'copy:concatStyles'

			# Minify the script file.
			'uglify:generated'

			# Create the require bundle.
			'uglify:requirejs'
			'requirejs:distribution'

			# Copy static assets, such as fonts or text files.
			'copy:distribution'

			# Rename the files to avoid cashe issues.
			'rev'

			# Wraps up many usefull things.
			'usemin'

			if debug then 'htmlmin:debug' else 'htmlmin:distribution'
		]

		# Archive this build.
		if grunt.option 'archive'
			grunt.task.run 'archive'
