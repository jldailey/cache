module.exports = function (grunt) {
	grunt.initConfig({
		nodeunit: {
			all: ['**/*.test.coffee', '!node_modules/**']
		}
	});

	grunt.loadNpmTasks('grunt-contrib-nodeunit');
};
