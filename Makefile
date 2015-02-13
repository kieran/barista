test:
	@mocha --reporter list --growl --compilers coffee:coffee-script/register tests/mocha.coffee

oldtest:
	@coffee tests/barista.test.coffee

debug_test:
	@coffee --nodejs --debug-brk tests/barista.test.js

autotest:
	@mocha --watch lib/ --reporter list --growl --compilers coffee:coffee-script/register tests/mocha.coffee

browser:
	@browserify -t coffeeify --extension=".coffee" browser.js -o dist/barista.js
