gulp       = require "gulp"
coffee     = require "gulp-coffee"
rimraf     = require "gulp-rimraf"
coffeelint = null
jshint     = null
nodeunit   = null

nodeunitReporter = process.env.NODEUNIT_REPORTER || "default"
nodeunitOutput   = process.env.NODEUNIT_OUTPUT   || "test"

dist = "dist"
coffeeFiles = [
	"lib/**/*.coffee"
	"!**/*.test.coffee"
]
jsFiles = [
	"lib/**/*.js"
	"!**/*.test.js"
]
testFiles = [
	"lib/**/*.test.coffee"
	"lib/**/*.test.js"
]
allCoffeeFiles = [
	"lib/**/*.coffee"
	"gulpfile.coffee"
]
allJSFiles = [
	"lib/**/*.js"
	"gulpfile.js"
]
allFiles = allCoffeeFiles.concat allJSFiles

# Hack to allow non-build tasks to have dev only dependencies
start = gulp.start
gulp.start = (tasks) ->
	if tasks isnt "build"
		coffeelint = require "gulp-coffeelint"
		jshint     = require "gulp-jshint"
		nodeunit   = require "gulp-nodeunit"

	gulp.start = start
	start.apply gulp, arguments

errorHandler = ->
	process.exit -1

gulp.task "clean", ->
	gulp.src dist, read: false
		.pipe rimraf null

gulp.task "coffee-lint", ->
	config =
		no_tabs:
			level: "ignore"
		indentation:
			value: 1

	gulp.src allCoffeeFiles
		.pipe coffeelint config
		.pipe coffeelint.reporter "default"
		.pipe coffeelint.reporter "fail"
			.on "error", errorHandler

gulp.task "js-lint", ->
	gulp.src allJSFiles
		.pipe jshint null
		.pipe jshint.reporter "default"
		.pipe jshint.reporter "fail"
			.on "error", errorHandler

gulp.task "lint", [
	"coffee-lint"
	"js-lint"
]

gulp.task "compile-coffee", ["clean"], ->
	gulp.src coffeeFiles
		.pipe coffee null
		.pipe gulp.dest dist

gulp.task "copy-js", ["clean"], ->
	gulp.src jsFiles
		.pipe gulp.dest dist

gulp.task "build", [
	"compile-coffee"
	"copy-js"
]

gulp.task "nodeunit", ->
	options = require "gulp-nodeunit/node_modules/nodeunit/bin/nodeunit.json"
	options.output = nodeunitOutput

	gulp.src(testFiles)
		.pipe nodeunit
			reporter: nodeunitReporter,
			reporterOptions: options

gulp.task "test", [
	"lint"
	"nodeunit"
]

gulp.task "develop", ["test"], ->
	errorHandler = ->
	gulp.watch allFiles, ["test"]

gulp.task "default", [
	"test"
	"build"
]
