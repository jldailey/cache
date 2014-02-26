gulp       = require("gulp")
coffee     = require("gulp-coffee")
coffeelint = require("gulp-coffeelint")
jshint     = require("gulp-jshint")
rimraf     = require("rimraf")

dist = "dist"
scriptFiles = [
	"**/*.coffee"
	"!gulpfile.coffee"
	"!node_modules/**"
	"!**/*.test.coffee"
]
testFiles = [
	"**/*.test.coffee"
	"!node_modules/**"
]

gulp.task "clean", (done) ->
	rimraf dist, done
	return

gulp.task "lint", ->
	gulp.src scriptFiles
		.pipe coffeelint
			no_tabs:
				level: "ignore"
			indentation:
				value: 1
		.pipe coffeelint.reporter()

gulp.task "build", ->
	gulp.src scriptFiles
		.pipe coffee()
		.pipe gulp.dest dist

# TODO: Add a gulp nodeunit runner and remove the grunt dependency
require("gulp-grunt") gulp
gulp.task "test", ["grunt-nodeunit"]
gulp.task "develop", ->
	gulp.watch scriptFiles.concat testFiles, [
		"lint"
		"test"
	]

gulp.task "dist", [
	"lint"
	"test"
	"clean"
	"build"
]
gulp.task "default", ["dist"]
