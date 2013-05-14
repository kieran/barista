test:
	@./node_modules/.bin/mocha --reporter list --growl --compilers coffee:coffee-script tests/mocha.coffee

oldtest:
	@node tests/barista.test.js

autotest:
	@cd lib; ../node_modules/.bin/mocha -w --reporter list --growl --compilers coffee:coffee-script ../tests/mocha.coffee
