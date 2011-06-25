Barista is a simple URL router for nodejs.

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


### Adding routes

```javascript
// a basic example
router.match( '/products', 'GET' )
      .to( 'products.index' )

// Rails-style variables
router.match( '/products/:id', 'GET' )
      .to( 'products.show' )

// optional parts
router.match( '/products/:id(.:format)', 'GET' )
      .to( 'products.show' )

// convenience methods
router.get( '/products/:id(.:format)' )
      .to( 'products.show' )

router.put( '/products/:id(.:format)' )
      .to( 'products.update' )

router.post( '/products' )
      .to( 'products.create' )

router.delete( '/products' )
      .to( 'products.destroy' )
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

router.delete('/products/:id(.:format)' )
      .to( 'products.destroy' )
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