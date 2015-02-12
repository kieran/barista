test:
	@mocha --reporter list --growl --compilers coffee:coffee-script/register tests/mocha.coffee

oldtest:
	@node tests/barista.test.js

debug_test:
	@node --debug-brk tests/barista.test.js

autotest:
	@mocha --watch lib/ --reporter list --growl --compilers coffee:coffee-script/register tests/mocha.coffee

browser:
	@browserify -t coffeeify --extension=".coffee" browser.js -o dist/barista.js
