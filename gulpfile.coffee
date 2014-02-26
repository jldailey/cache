gulp       = require("gulp")
coffee     = require("gulp-coffee")
coffeelint = require("gulp-coffeelint")
jshint     = require("gulp-jshint")
nodeunit   = require("gulp-nodeunit")
rimraf     = require("rimraf")

dist = "dist"
scriptFiles = [
	"**/*.coffee"
	"!gulpfile.coffee"
	"!**/*.test.coffee"
	"!node_modules/**"
]
testFiles = [
	"**/*.test.coffee"
	"!node_modules/**"
]
allFiles = [
	"**/*.coffee"
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

gulp.task "test", ->
	gulp.src testFiles
		.pipe nodeunit({
			reporter: process.env.NODEUNIT_REPORTER ? 'default',
			reporterOptions: {
				output: "dist"
			}
		})

gulp.task "develop", [
	"lint"
	"test"
], ->
	gulp.watch allFiles, [
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
