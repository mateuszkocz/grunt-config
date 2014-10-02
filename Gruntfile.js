'use strict';

module.exports = function ( grunt ) {
	// Measures the time Grunt plugins took to execute.
	require( 'time-grunt' )( grunt );

	// Initialises all Grunt plugins.
	require( 'load-grunt-tasks' )( grunt );

	// Application configuration.
	var config = {
		// Some tasks change their configuration depending on the
		// state of the debug environment. Don't change the variable, though.
		// Use `grunt task --debug`.
		debug: false,

		// The App's source files.
		app: 'app',

		// The build's destination catalogue.
		dist: 'dist',

		// The path referred to when accessing libraries.
		lib: '/libraries',

		// The catalogue where Bower libraries are downloaded into.
		components: './bower_components',

		// Port used to serve application in a browser.
		port: 9000,

		// Livereload's port
		livereloadPort: 35729,

		// Hostname to allow remote connections.
		hostname: '0.0.0.0',

		// Port used to allow a remote connection to the app's
		// local server made by the connect:local task.
		remotePort: 9001
	};

	grunt.initConfig( {
		// Import the configuration.
		config: config,

		// Get the app's information.
		pkg: grunt.file.readJSON( 'package.json' ),

		// Documentation: https://github.com/gruntjs/grunt-contrib-watch
		watch: {
			// The watch task will be reloaded on the Gruntfile's change.
			gruntfile: {
				files: ['Gruntfile.js']
			},

			js: {
				files: ['<%= config.app %>/scripts/{,*/}*.js'],
				options: {
					livereload: true
				}
			},

			styles: {
				files: ['<%= config.app %>/styles/{,*/}*.css'],
				tasks: ['newer:copy:styles', 'autoprefixer']
			},

			less: {
				files: ['<%= config.app %>/styles/{,*/}*.less'],
				tasks: ['less:development', 'autoprefixer']
			},

			// Livereload's options and paths to files that don't require
			// running special tasks.
			livereload: {
				options: {
					livereload: '<%= config.livereloadPort %>'
				},
				files: [
					'<%= config.app %>/{,*/}*.html',
					'.tmp/styles/{,*/}*.css'
				]
			}
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-connect
		connect: {
			// Basic connection options.
			options: {
				port: '<%= config.port %>',
				livereload: '<%= config.livereloadPort %>',

				// Open a browser.
				open: true,

				// By default make the app visible only on the computer.
				hostname: 'localhost'
			},

			// Starts a development server.
			development: {
				options: {
					// Defines the paths that will be used by the server.
					middleware: function ( connect ) {
						return [
							connect.static( '.tmp' ),
							connect().use( config.lib, connect.static( config.components ) ),
							connect.static( config.app )
						]
					}
				}
			},

			// Starts a local server with a distribution version of the app.
			local: {
				options: {
					base: '<%= config.dist %>',
					livereload: false,

					// Makes it visible from the outside
					hostname: '<%= config.hostname %>',
					port: '<%= config.remotePort %>'
				}
			}
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-clean
		clean: {
			// Clean the .tmp catalogue and the distribution's target catalogue.
			dist: {
				files: [
					{
						dot: true,
						src: [
							'.tmp',
							'<%= config.dist %>/*',
							'!<%= config.dist %>/.git*'
						]
					}
				]
			},
			// Just clean the .tmp catalogue.
			server: '.tmp'
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-copy
		copy: {
			// Copy files not processed in any other task.
			dist: {
				files: [
					{
						expand: true,
						dot: true,
						cwd: '<%= config.app %>',
						dest: '<%= config.dist %>',
						src: [
							'{,*/}*.html', // FIXME: htmlmin should process and move the files, except for the index file.
							'*.{ico,png,txt,md}', // Favicons and text files
							'images/{,*/}*.webp', // .webp is not minified by the imagemin.
							'fonts/{,*/}*.*',
							'assets/{,*/}*.*' // Additional assets the project migh have (like PDFs)
						]
					},
					{
						// Apache configuration from the apache-server-configs module.
						src: 'node_modules/apache-server-configs/dist/.htaccess',
						dest: '<%= config.dist %>/.htaccess'
					}
				]
			},

			// Copy .css files to the temp directory, so they can be later processed.
			styles: {
				expand: true,
				dot: true,
				cwd: '<%= config.app %>/styles',
				dest: '.tmp/styles/',
				src: '{,*/}*.css'
			},

			// Copy .js files to the temp directory, so they can be later processed.
			scripts: {
				expand: true,
				dot: true,
				cwd: '<%= config.app %>/scripts',
				dest: '.tmp/scripts',
				src: '{,*/}*.js'
			}
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-less
		less: {
			options: {},
			development: {
				options: {
					sourceMap: true // FIXME: doesn't generate a map.
					// TODO: more source map options to allow editing in the file
				},
				files: {
					'.tmp/styles/less.css': '<%= config.app %>/styles/index.less'
				}
			},
			dist: {
				files: {
					'.tmp/styles/less.css': '<%= config.app %>/styles/index.less'
				}
			}
		},

		// Documentation: https://github.com/nDmitry/grunt-autoprefixer
		autoprefixer: {
			options: {
				browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1']
			},

			// The plugin requires a target.
			dist: {
				files: [
					{
						expand: true,
						dot: true,
						cwd: '.tmp/styles/',
						src: '{,*/}*.css',
						dest: '.tmp/styles/'
					}
				]
			}
		},

		// Documentation: https://github.com/cbas/grunt-rev
		rev: {
			dist: {
				files: {
					src: [
						'<%= config.dist %>/scripts/{,*/}*.js',
						'<%= config.dist %>/styles/{,*/}*.css',
						'<%= config.dist %>/images/{,*/}*.*',
						'<%= config.dist %>/styles/fonts/{,*/}*.*',
						'<%= config.dist %>/*.{ico,png}'
					]
				}
			}
		},

		// Reads the HTML for usemin blocks to enable smart builds that automatically
		// concat, minify and revision files. Creates configurations in memory so
		// additional tasks can operate on them
		// Documentation: https://github.com/yeoman/grunt-usemin
		useminPrepare: {
			options: {
				dest: '<%= config.dist %>'
			},
			html: '<%= config.app %>/index.html'
		},

		// Performs rewrites based on the rev and the useminPrepare configuration
		// Documentation: https://github.com/yeoman/grunt-usemin
		usemin: {
			options: {
				assetsDirs: ['<%= config.dist %>', '<%= config.dist %>/images'],
				patterns: {
					// Rename references in JavaScript files.
					// Solution: https://github.com/yeoman/grunt-usemin/issues/235
					js: [
						[/(images\/.*?\.(?:gif|jpeg|jpg|png|webp|svg))/gm, 'Update the JS to reference our revved images']
					]
				}
			},
			html: ['<%= config.dist %>/{,*/}*.html'],
			css: ['<%= config.dist %>/styles/{,*/}*.css'],
			js: ['<%= config.dist %>/scripts/{,*/}*.js']
		},

		// The concatm uglify and cssmin tasks' options are defined automatically by the usemin
		// task. If you want to add a custom behaviour, read the usemin's docs.

		// Documentation: https://github.com/gruntjs/grunt-contrib-concat
		concat: {
			// Settings for the task are provided by the usemin task.
			// The task moves concatenated files into the dist catalogue
			// so the usemin can then rev them and apply other necessary actions.
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-cssmin
		cssmin: {
			// Only the global options. The files are managed by the usemin task.
			options: {
				report: 'gzip',
				banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %> */'
			}
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-uglify
		uglify: {
			options: {
				compress: {
					// Set a value for some variables.
					global_defs: {
						'DEBUG': false
					},
					dead_code: true,
					drop_console: true,
				},
				preserveComments: 'some',
				report: 'gzip',
				banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %> */\n'
			},
			debug: {
				options: {
					mangle: false,
					compress: false,
					sourceMap: true,
					beautify: true,
					banner: '/*! <%= pkg.name %> - v<%= pkg.version %>-debug - <%= grunt.template.today("yyyy-mm-dd") %> */\n'
				}
			}
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-imagemin
		imagemin: {
			dist: {
				files: [
					{
						expand: true,
						cwd: '<%= config.app %>/images',
						src: '{,*/}*.{gif,jpeg,jpg,png}',
						dest: '<%= config.dist %>/images'
					}
				]
			}
		},

		// Documentation: https://github.com/sindresorhus/grunt-svgmin
		svgmin: {
			dist: {
				files: [
					{
						expand: true,
						cwd: '<%= config.app %>/images',
						src: '{,*/}*.svg',
						dest: '<%= config.dist %>/images'
					}
				]
			}
		},

		// Documentation: https://github.com/gruntjs/grunt-contrib-htmlmin
		htmlmin: {
			options: {
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
			},
			dist: {
				options: {
					collapseWhitespace: true,
					conservativeCollapse: true,
					minifyJS: true,
					minifyCSS: true
				},
				files: [
					{
						expand: true,
						cwd: '<%= config.dist %>',
						src: '{,*/}*.html',
						dest: '<%= config.dist %>'
					}
				]
			},
			debug: {
				options: {},
				files: [
					{
						expand: true,
						cwd: '<%= config.dist %>',
						src: '{,*/}*.html',
						dest: '<%= config.dist %>'
					}
				]
			}
		},

		// Documentation: https://github.com/sindresorhus/grunt-concurrent
		concurrent: {
			development: [
				// Copy styles, so they can be autoprefixed.
				'copy:styles',

				// Compile the development version of less files.
				'less:development'
			],
			dist: [
				// Images minification.
				'imagemin',
				'svgmin',

				// Styles coompilation and related tasks.
				'copy:styles',
				'less:dist',

				// SCripts compilation and related tasks.
				'copy:scripts'
				// TODO: JS processors...
			]
		}
	} );

	// Make the run task the default.
	grunt.registerTask( 'default', function () {
		grunt.task.run( 'run' );
	} );

	// The run task starts a development server.
	grunt.registerTask( 'run', [
		// Clean the temp catalogue.
		'clean:server',

		// Preprocessors.
		'concurrent:development',

		// Autoprefix CSS files.
		'autoprefixer',

		// Create the development server.
		'connect:development',

		// Run the watch task.
		'watch'
	] );

	// Alias tasks for distribution and debug build environments.
	// TODO: the dist task should do more than just build the app.
	// Eg. add version in package.json, put the git tag, create a package
	// or upload the files on a server.
	grunt.registerTask( 'dist', ['build:dist'] );
	grunt.registerTask( 'dist-debug', ['build:debug'] );

	// The build task. By default builds a release ready application.
	grunt.registerTask( 'build', 'Build the app', function ( env ) {
		// Check for a debug request ( can be done by --debug and build:debug );
		var debug = grunt.option('debug') || env === 'debug';

		// Make required changes when the debug build was requested.
		if ( debug ) {
			grunt.log.writeln( 'Debug build initiated.' );

			// Set the global debug flag. Some tasks' configuration might
			// change depending on the value of the debug environment.
			// TIP: you can use '<% config.debug %>' ? _isDebug_ : _isProduction_
			// when configuring tasks.
			grunt.config.set('config.debug',true);

			// Set some tasks' options manually here, since they use the usemin's
			// automatic configuration, so you can't easily point them to the wanted target.
			grunt.config.set('uglify.options', grunt.config.get('uglify.debug.options'));

			// TODO: more tasks to use the --debug.
		} else {
			grunt.log.writeln( 'Executing a release build.' );
		}

		grunt.task.run( [
			// Clean the temp and distribution catalogues.
			'clean:dist',

			// Make necessary preparations for other tasks.
			'useminPrepare',

			// Do some paralel tasks, such as preprocessors compilation.
			'concurrent:dist',

			// Vendor-prefix the CSS
			'autoprefixer',

			// Combine scripts and styles to make a single file for each.
			'concat',

			// Minify the style sheet.
			'cssmin',

			// Minify the script file.
			'uglify',

			// Copy static assets, such as fonts or text files.
			'copy:dist',

			// Rename the files to avoid cashe issues.
			'rev',

			// Wraps up many usefull things.
			'usemin'
		] );

		// Run the HTML minification according to the requested type of the build.
		if ( debug ) grunt.task.run( 'htmlmin:debug' );
		else grunt.task.run( 'htmlmin:dist' );

	} );
};
