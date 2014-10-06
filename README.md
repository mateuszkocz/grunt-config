Application foundation. Strongly based on the Yeoman Webapp.

# Tasks

## `grunt`
### Description
Default task and a shortcut to the development task.
Runs the development environment. See the `grunt develop` task description.

**TODO**: Rather than starting the development environment, should be used to
test and build the app.

## `grunt develop`
### Description
Starts the development environment that watches the files, compiles them as needed
(LESS and CoffeScript - more to come) and livereload changes. The app is available
locally in browsers on the host and port defined in the config.

You can use this task for a complete workflow, or just use its watching abilities
when the liverelod is provided by some other tool (eg. your IDE or text editor).

### Options
#### `--open`
Opens the app in the default browser.

## `grunt develop:open`
### Description
Same as `grunt develop --open`.

## `grunt build`
### Description
Creates the release-ready version of the application with all scritps and
styles combined and minified, files' names rewritten and with other useful tasks
done.

### Options
#### `--debug`
Creates a debug build. Scripts and styles are compiled and concatenated but
not minified and source maps are generated for them. Comments are left intact.
Grunt's debug logs will be printed in the terminal, since it is also
one of the Grunt's options.

Alternatively you can use the `grunt build:debug task` (though you won't get
the Grunt's debug logs).

#### `--archive`
Creates a zip package with the built version of application. Stored in the
archive folder.

## `grunt build:debug`
### Description
Alternative way of calling `grunt build --debug` with the only difference that
you won't get the Grunt's debug logs.

### Options
Same as in the `build` task.

## `grunt serve`
### Description
Builds the app and starts a server accessible from the outside. Similarly to
the `build` task, can be invoked as `serve:debug`. The outcome will be the
same as in the `build:debug` task, plus the server.

### Options
#### `--debug`
Serves the debug version of the application, as defined in the `grunt build --debug`
task.

#### `--open`
Opens the app in the default browser.

## `grunt archive`
### Description
Creates an archive of the current build (files in the dist directory). Usually it
is called in the build task when the `--archive` option is enabled to store the
fresh version, but can be used alone. In this case the only caveat is that if you
want to have the "-debug" suffix in the archive's name you need to add the `--debug`
flag manually.


# Configuration
TODO: Describe the configuration options.


# Todos
* TypeScript
* SASS/SCSS support
* RequireJS and Browserify support
* Modernizr support
* Tests
* Support for templates (HAML, Jade)
* JSHint (as in the watch task in the Yo Webapp)


# Ideas:
* GIT support (I) - eg. fetching from remotes when watch task active.
* GIT support (II) - git init as an option. Also it might be a good idea to
create a git submodule in the archive directory to store only the builds.
