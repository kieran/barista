test:
	@mocha --reporter list --growl --compilers coffee:coffee-script tests/mocha.coffee

oldtest:
	@node tests/barista.test.js

autotest:
	@cd lib; mocha -w --reporter list --growl --compilers coffee:coffee-script ../tests/mocha.coffee
