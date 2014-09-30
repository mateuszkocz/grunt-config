Application foundation. Strongly based on the Yeoman Webapp.

TODOS:
* CoffeeScript, TypeScript, Dart support
* SASS/SCSS support
* RequireJS support
* Modernizr support
* Tests
* Support for templates (HAML, Jade)
* Running local server accessible from the outside
* JSHint (as in the watch task in the Yo Webapp)
* prevent opening a browser with serve task (eg. --prevent-open)


Ideas:
* GIT support (eg. fetching from remotes when watch task active)

Bugs:
* LLibraries, that are accessible with path /libraries in the watch task are
  unreachable when building.
