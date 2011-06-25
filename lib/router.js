var Route     = require('./route').Route,
    snakeize  = require('./helpers').snakeize


// new Router()
// ============
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
var Router = function() {

  var METHODS = /^(GET|POST|PUT|DELETE)$/i,
      self = this

  this.routes = []
  
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
  this.match = function( path, method ) {

    if ( typeof path != 'string' ) throw 'path must be a string'

    if ( typeof method != 'undefined' && !METHODS.test(method)) throw 'method must be one of: get, post, put, delete'

    var route = new Route(path, method)
    self.routes.push(route)

    return route
  };

  // convenience methods
  // -------------------

  // ### router.get( path )
  // equivalent to
  //
  //     router.match( path, 'GET' )
  this.get = function( path ){
    return this.match(path, 'GET')
  }
  // ### router.put( path )
  // equivalent to
  //
  //     router.match( path, 'PUT' )
  this.put = function( path ){
    return this.match(path, 'PUT')
  }
  // ### router.post( path )
  // equivalent to
  //
  //     router.match( path, 'POST' )
  this.post = function( path ){
    return this.match(path, 'POST')
  }
  // ### router.delete( path )
  // equivalent to
  //
  //     router.match( path, 'DELETE' )
  this.delete = function( path ){
    return this.match(path, 'DELETE')
  }

  // router.resource( controller )
  // -----------------------------
  // generates standard resource routes for a controller name
  //
  //     router.resource('products')
  // 
  // returns an array of routes (for now, this may change)
  this.resource = function( controller ) {
    var controller_slug = snakeize(controller)
    return [
      self.get('/'+controller_slug+'(.:format)', 'GET').to(controller+'.index'),
      self.get('/'+controller_slug+'/add(.:format)', 'GET').to(controller+'.add'),
      self.get('/'+controller_slug+'/:id(.:format)', 'GET').to(controller+'.show'),
      self.get('/'+controller_slug+'/:id/edit(.:format)', 'GET').to(controller+'.edit'),
      self.post('/'+controller_slug+'(.:format)', 'POST').to(controller+'.create'),
      self.put('/'+controller_slug+'/:id(.:format)', 'PUT').to(controller+'.update'),
      self.delete('/'+controller_slug+'/:id(.:format)', 'DELETE').to(controller+'.destroy')
    ];
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
  this.first = function( path, method, cb ) {
    var params = false
    
    for (var i in self.routes) {
      
      // attempt the parse
      params = self.routes[i].parse(path, method)
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
  this.all = function( path, method ) {
    var ret = [],
        params = false

    for (var i in self.routes) {
      params = self.routes[i].parse(path, method)  // TODO: use call or apply (I forget which) to make 'method' optional
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
  this.url = function( params, add_querystring ) {
    var url = false
        
    // iterate through the existing routes until a suitable match is found
    for (var i in self.routes) {
      // do the controller & acton match?
      if (typeof(self.routes[i].params.controller) != 'undefined' &&
          self.routes[i].params.controller != params.controller) {
        continue
      }
      if (typeof(self.routes[i].params.action) != 'undefined' &&
          self.routes[i].params.action != params.action) {
        continue
      }
      url = self.routes[i].stringify(params);
      if (url) {
        break;
      }
    } 

    if (!url) return false  // no love? return false

    var qs = require('querystring').stringify(url[1])  // build the possibly empty query string

    if (add_querystring && qs.length > 0) return url[0] + '?' + qs  // if there is a query string...

    return url[0]  // just return the url
  };


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
  this.defer = function( fn ) {
    if ( typeof(fn) != 'function' ) throw 'Router.defer requires a function as the only argument'
     
    var route = new Route('deferred')
    route.parse = fn // add the custom parser
    delete route.test // = function(){return false};
    delete route.stringify //= function(){ throw 'Deferred routes are NOT generatable'};
    self.routes.push(route)
    return route
  }

}; // Router

exports.Router = Router