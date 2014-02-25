
DIST_FILES=$(shell ls *.coffee | sed -e 's@^@dist/@' -e 's/\.coffee/.js/' - )
COFFEE=node_modules/.bin/coffee
NODEUNIT=node_modules/.bin/nodeunit

all: $(DIST_FILES)

${NODEUNIT}:
	npm install nodeunit

test: all
	(${NODEUNIT} dist/test.js && \
		${NODEUNIT} --reporter junit dist/test.js --output dist)

dist/%.js: %.coffee
	${COFFEE} -o dist -c $<

