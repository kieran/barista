var Route     = require('./route').Route
  , Resource  = require('./resource').Resource
  , qstring   = require('querystring')


// new Router
// ==========
// Simple router for Node -- setting up routes looks like this:
//
//      router = new Router();
//
//      router.match('/')
//       .to('application.index')
//       .name('main');
//
//      router.match('/users/:user_id/messages/:message_id')
//       .to('users.read_message');
//
// Pretty familiar to anyone who's used Merb/Rails
//
var Router = exports.Router = function() {

  this.METHODS = [ 'GET', 'HEAD', 'POST', 'PUT', 'DELETE' ]
  this.routes = []

  return this
}; // Router


// router.match( path [, method] )
// -------------------------------
//
//     router.match('/:controller/:action(/:id)(.:format)', 'GET')
//      .to(......)
//
// path is mandatory (duh)
// method is optional, routes without a method will apply in all cases
//
// returns the route (for chaining)
//
Router.prototype.match = function( path, method ) {

  if ( typeof method == 'string' ) method = method.toUpperCase()

  if ( typeof method != 'undefined' && !this.methods_regexp().test(method)) throw new Error('method must be one of: ' + this.METHODS.join(', '))

  var route = new Route( this, path, method)
  // this.routes.push(route)
  return route
};


// convenience methods
// -------------------

  // ### router.get( path )
  // equivalent to
  //
  //     router.match( path, 'GET' )
  //
  Router.prototype.get = function( path ){
    return this.match(path, 'GET')
  }

  // ### router.put( path )
  // equivalent to
  //
  //     router.match( path, 'PUT' )
  //
  Router.prototype.put = function( path ){
    return this.match(path, 'PUT')
  }

  // ### router.post( path )
  // equivalent to
  //
  //     router.match( path, 'POST' )
  //
  Router.prototype.post = function( path ){
    return this.match(path, 'POST')
  }

  // ### router.del( path )
  // equivalent to
  //
  //     router.match( path, 'DELETE' )
  //
  Router.prototype.del = function( path ){
    return this.match(path, 'DELETE')
  }


// router.resource( controller )
// -----------------------------
// generates standard resource routes for a controller name
//
//     router.resource('products')
//
// returns a Resource object
//
Router.prototype.resource = function( controller ) {
  var resource = new Resource( this, controller )
  return resource
};


// router.first( path, method, callback )
// ----------------------------
// find the first route that match the path & method
//
//     router.first('/products/5', 'GET')
//     => { controller: 'products', action: 'show', id: 5, method: 'GET' }
//
// find & return a params hash from the first route that matches. If there's no match, this will return false
//
// If the options callback function is provided, it will be fired like so:
//
//     callback( error, params )
//
Router.prototype.first = function( path, method, cb ) {
  var params = false

  for (var i in this.routes) {
    // attempt the parse
    params = this.routes[i].parse(path, method)
    if (params) {
      // fire the callback if given
      if (typeof cb == 'function') cb(false, params)
      // may as well return this
      return params
    }
  }

  if (typeof cb == 'function') cb('No matching routes found')
  return false
};


// router.all( path [, method] )
// --------------------------
// find & return a params hash from ALL routes that match
//
//     router.all( '/products/5' )
//
//       => [
//         { controller: 'products', action: 'show', id: 5, method: 'GET' },
//         { controller: 'products', action: 'update', id: 5, method: 'PUT' },
//         { controller: 'products', action: 'destroy', id: 5, method: 'DELETE' },
//       ]
//
// if there ares no matches, returns an empty array
//
Router.prototype.all = function( path, method ) {
  var ret = [],
      params = false

  for (var i in this.routes) {
    params = this.routes[i].parse.apply(this.routes[i], arguments)
    if (params) ret.push(params)
  }
  return ret;
};


// router.url( params[, add_querystring=false] )
// --------------------------------------------
// generates a URL from a params hash
//
//     router.url( {
//       controller: 'products',
//       action: 'show',
//       id: 5
//     } )
//     => '/products/5'
//
//     router.url( {
//       controller: 'products',
//       action: 'show',
//       id: 5,
//       format: 'json'
//     } )
//     => '/products/5.json'
//
//     router.url({
//       controller: 'products',
//       action: 'show',
//       id: 5,
//       format: 'json',
//       love: 'cheese'
//     }, true )
//     => '/products/5.json?love=cheese'
//
// returns false if there are no suitable routes
//
Router.prototype.url = function( params, add_querystring ) {
  var url = false

  // iterate through the existing routes until a suitable match is found
  for (var i in this.routes) {
    // do the controller & acton match?
    if (typeof(this.routes[i].params.controller) != 'undefined' &&
        this.routes[i].params.controller != params.controller) {
      continue
    }
    if (typeof(this.routes[i].params.action) != 'undefined' &&
        this.routes[i].params.action != params.action) {
      continue
    }
    url = this.routes[i].stringify(params);
    if (url) {
      break;
    }
  }

  if (!url) return false  // no love? return false

  var qs = qstring.stringify(url[1])  // build the possibly empty query string

  if (add_querystring && qs.length > 0) return url[0] + '?' + qs  // if there is a query string...

  return url[0]  // just return the url
};

Router.prototype.methods_regexp = function(){
  return RegExp('^(' + this.METHODS.join('|') + ')$','i')
}


// router.defer( testfn() )
// ------------------------
//
//     router.defer( test( path, method ) )
//
// test should be a function that examines non-standard URLs
//
// path and method will be passed in - expects a params hash back OR false on a non-match
//
// returns: DeferredRoute (for... reference? I dunno.)
//
// **THIS IS CURRENTLY COMPLETELY UNTESTED. IT MIGHT NOT EVEN WORK. SERIOUSLY.**
//
Router.prototype.defer = function( fn ) {
  if ( typeof(fn) != 'function' ) throw new Error('Router.defer requires a function as the only argument')

  var route = new Route(this, 'deferred')
  route.parse = fn // add the custom parser
  delete route.test // = function(){return false};
  delete route.stringify //= function(){ throw new Error('Deferred routes are NOT generatable')};
  this.routes.push(route)
  return route
}


Router.prototype.toString = function(){
  return this.routes.map(function(rt){return rt.toString()}).join('\n')
}