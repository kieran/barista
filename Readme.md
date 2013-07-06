Barista is a simple URL router for NodeJS.


In a nutshell
=============

```javascript
router.get( '/:beverage/near/:location(.:format)' )
      .to( 'beverage.byLocation' )

router.first( '/coffee/near/90210', 'GET' )
// -> { controller:'beverage', action:'byLocation', beverage:'coffee', location:90210 }

router.url({
  controller: 'beverage',
  action: 'byLocation',
  beverage: 'coffee',
  location: 90210,
  format: 'json'
})
// -> '/coffee/near/90210.json'
```


Getting Barista
===============

Install via npm, thusly:

```javascript
npm install barista
```

Using Barista
-------------

```javascript
var Router = require('barista').Router;

var router = new Router;
```

Adding routes
-------------

### A simple example

```javascript
router.match( '/products', 'GET' )
      .to( 'products.index' )
```

### Rails-esque variable names

```javascript
router.match( '/products/:id', 'GET' )
      .to( 'products.show' )

router.match( '/profiles/:username', 'GET' )
      .to( 'users.show' )

router.match( '/products/:id(.:format)', 'GET' )
      .to( 'products.show' )
```

### Globs (they also capture slashes)

```javascript
router.get('/timezones/*tzname')
      .to( 'timezones.select' )

router.first( '/timezones/America/Toronto', 'GET' )
// -> { controller:'timezones', action:'select', tzname:'America/Toronto' }


router.match( '/*path(.:format)' ) // a "catch-all" route:
      .to( 'errors.notFound' )

router.first( '/somewhere/that/four-oh-fours.json', 'GET' )
// -> { controller:'errors', action:'notFound', path:'somewhere/that/four-oh-fours', format:'json' }
```

### Match conditions

```javascript
router.match( '/:beverage/near/:zipcode', 'GET' )
      .to( 'beverage.byZipCode' )
      .where({
        // an array of options
        beverage: [ 'coffee', 'tea', 'beer', 'warm_sake' ],
        // a regex pattern
        zipcode: /^\d{5}(-\d{4})?$/
      })

router.match( '/:beverage/near/:location', 'GET' )
      .to( 'beverage.byLocation' )
      .where({
        // could be a postal code
        // OR a zip code
        // OR the word 'me' (geolocation FTW)
        location: [ /^\d{5}(-\d{4})?$/, /^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$/, 'me' ]
      })
```

### Convenience methods

```javascript
router.get( '/products/:id(.:format)' )
      .to( 'products.show' )

router.put( '/products/:id(.:format)' )
      .to( 'products.update' )

router.post( '/products' )
      .to( 'products.create' )

router.del( '/products' )
      .to( 'products.destroy' )

router.options( '/products' )
      .to( 'products.options' )
```

### REST Resources

```javascript
router.resource( 'products' )
```

is equivalent to:

```javascript
router.get( '/products(.:format)' )
      .to( 'products.index' )

router.get( '/products/add(.:format)' )
      .to( 'products.add' )

router.get( '/products/:id(.:format)' )
      .to('products.show' )

router.get('/products/:id/edit(.:format)' )
      .to( 'products.edit' )

router.post('/products(.:format)' )
      .to( 'products.create' )

router.put('/products/:id(.:format)' )
      .to( 'products.update' )

router.del('/products/:id(.:format)' )
      .to( 'products.destroy' )
```

Removing Routes
------------------------

In some cases, you will need to remove routes on a running router.  The `router.remove( name )` method will work for this, but requires
use of the otherwise unused `route.name( name )` method.

### Adding a name (currently only used with this functionality)

```javascript
router.match( '/products/:id', 'GET' )
      .to( 'products.show' )
      .name('products_show')
```

### Removing a named route

```javascript

router.remove('products_show')

```

Resolution & dispatching
------------------------

The `router.first( url, method [, callback] )` method can be used in two ways:

```javascript
var params = router.first( '/products/15', 'GET' )
```

OR

```javascript
router.first( '/products/15', 'GET', function( params ){
  // dispatch the request or something
})
```

You can get all the matching routes like so:

```javascript
var params = router.all( '/products/15', 'GET' )

//=> [params, params, params....]
```

Route generation
----------------

Pass in a params hash, get back a tasty string:

```javascript
router.url( {
  controller: 'products',
  action: 'show',
  id: 5
} )
//=> '/products/5'

router.url( {
  controller: 'products',
  action: 'show',
  id: 5,
  format: 'json'
} )
//=> '/products/5.json'
```

Set the optional second parameter to `true` if you want
extra params appended as a query string:

```javascript
router.url({
  controller: 'products',
  action: 'show',
  id: 5,
  format: 'json',
  love: 'cheese'
}, true )
//=> '/products/5.json?love=cheese'
```


Caveats & TODOs
---------------
nested optional segments are currently unsupported. e.g. this won't work:

```javascript
router.get( '/:controller(/:action(/:id(.:format)))' )
```

nesting routes & resources is also still on the TODO list


Things I forgot...
------------------
...might be in the `/docs` folder...

...or might not exist at all.


It's broken!
------------
Shit happens.

Write a test that fails and add it to the tests folder,
then create an issue!

Patches welcome :-)


Who are you?
------------
I'm [Kieran Huggins](mailto:kieran@refactory.ca), partner at [Refactory](http://refactory.ca) in Toronto, Canada.
