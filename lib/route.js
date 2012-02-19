var Key           = require('./key').Key,
    regExpEscape  = require('./helpers').regExpEscape,
    mixin         = require('./helpers').mixin,
    kindof        = require('./helpers').kindof


// new Route( path [, method] )
// =================
// turns strings into magical ponies that come when you call them
//
//     route = new Route('/:controller/:action/:id(.:format)')
//     route = new Route('/:controller/:action(/:id)(.:format)', 'GET')
//     route = new Route('/:controller/:action(/:id)(.:format)',
//     route = new Route('/:controller/:action/:id(.:format)', 'GET')
//
// Pretty familiar to anyone who's used Merb/Rails - called by Router.match()
var Route = function( path, method ) {

  var self = this,
      // !x! regexen crossing !x!
      // matches keys
      KEY = /:([a-zA-Z_][\w\-]*)/,
      // matches globs
      GLOB = /\*([a-zA-Z_][\w\-\/]*)/,
      // optional group (the part in parens)
      OGRP = /\(([^)]+)\)/,
      // breaks a string into atomic parts: ogrps, keys, then everything else
      PARTS = /\([^)]+\)|:[a-zA-Z_][\w\-]*|\*[a-zA-Z_][\w\-]*|[\w\-_\\\/\.]+/g

  // is this a nested, optional url segment like (.:format)
  self.optional = false

  // uppercase the method name
  if (typeof(method) == 'string') self.method = method.toUpperCase()

  // base properties
  self.params = {}
  self.parts = []
  self.route_name = null
  self.path = path
  /*self.regex = null // for caching of test() regex MAYBE*/

  // route.regexString()
  // -------------------
  //
  // returns a composite regex string of all route parts
  this.regexString = function() {
    var ret = ''
    // a route regex is a composite of its parts' regexe(s|n)
    for (var i in self.parts) {
      var part = self.parts[i]
      if (part instanceof Key) {
        ret += part.regexString()
      } else if (part instanceof Route) {
        ret += part.regexString()
      } else { // string
        ret += regExpEscape(part)
      }
    }
    return '('+ret+')'+(self.optional ? '?' : '')
  };


  // route.test( string )
  // -----------
  // builds & tests on a full regex of the entire path
  //
  //     route.test( '/products/19/edit' )
  //      => true
  //
  // returns true/false depending on whether the url matches
  this.test = function( string ) {
    /*
    TODO cache this if it makes sense, code below:
    if(self.regex == null) self.regex = RegExp('^' +  self.regexString() + '(\\\?.*)?$')
    return self.regex.test(string)
    */
    return RegExp('^' +  self.regexString() + '(\\\?.*)?$').test(string)
  };

  // route.to( endpoint [, extra_params ] )
  // ------------------------------------------------------------------------------------
  // defines the endpoint & mixes in optional params
  //
  //     route.to( 'controller.action' )
  //
  //     route.to( 'controller.action', {lang:'en'} )
  //
  // returns the route for chaining
  this.to = function( endpoint, extra_params ) {

    if ( !extra_params && typeof endpoint != 'string' ) {
      extra_params = endpoint
      endpoint = undefined
    }

    /*
      TODO: make endpoint optional, since you can have the
      controller & action in the URL utself,
      even though that's a terrible idea...
    */

    if ( endpoint ){
      endpoint = endpoint.split('.')
      if( kindof(endpoint) == 'array' && endpoint.length != 2 ) throw 'syntax should be in the form: controller.action'
      this.params.controller = endpoint[0]
      this.params.action = endpoint[1]
    }

    extra_params = kindof(extra_params) == 'object' ? extra_params : {}
    mixin(self.params, extra_params)

    return this // chainable
  };

  // route.name( name )
  // ------------------
  // just sets the route name - NAMED ROUTES ARE NOT CURRENTLY USED
  //
  //     route.name( 'login' )
  //     route.name( 'homepage' ) // etc...
  //
  // returns: the route for chaining
  this.name = function( name ) {
    self.route_name = name
    return self // chainable
  };

  // route.where( conditions )
  // ---------------------
  // sets conditions that each url variable must match for the URL to be valid
  //
  //     route.where( { id:/\d+/, username:/\w+/ } )
  //
  // returns: the route for chaining
  this.where = function( conditions ) {

    var self = this

    if ( kindof(conditions) != 'object' ) throw 'conditions must be an object'

    for (var i in self.parts) {
      if (self.parts[i] instanceof Key || self.parts[i] instanceof Route) {
        // recursively apply all conditions to sub-parts
        self.parts[i].where(conditions)
      }
    }

    return self // chainable
  };

  // route.stringify( params )
  // -------------------------
  // builds a string url for this Route from a params object
  //
  // returns: [ "url", [leftover params] ]
  //
  // **this is meant to be called & modified by router.url()**
  this.stringify = function( params ) {
    var url = [] // urls start life as an array to enble a second pass

    for (var i in self.parts) {
      var part = self.parts[i]
      if (part instanceof Key) {
        if (typeof(params[part.name]) != 'undefined' &&
            part.regex.test(params[part.name])) {
          // there's a param named this && the param matches the key's regex
          url.push(part.url(params[part.name])); // push it onto the stack
          delete params[part.name] // and remove from list of params
        } else if (self.optional) {
          // (sub)route doesn't match, move on
          return false
        }
      } else if (part instanceof Route) {
        // sub-routes must be handled in the next pass
        // to avoid leftover param duplication
        url.push(part)
      } else { // string
        url.push(part)
      }
    }

    // second pass, resolve optional parts
    for (var i in url) {
      if (url[i] instanceof Route) {
        url[i] = url[i].stringify(params) // recursion is your friend
        // it resolved to a url fragment!
        if (url[i]) {
          // replace leftover params hash with the new, smaller leftover params hash
          params = url[i][1]
          // leave only the string for joining
          url[i] = url[i][0]
        } else {
          delete url[i] // get rid of these shits
        }
      }
    }

    for (var i in self.params) {
      // remove from leftovers, they're implied in the to() portion of the route
      delete params[i]
    }

    return [ url.join(''), params ]
  };


  // route.keysAndRoutes()
  // ---------------------
  // just the parts that aren't strings. basically
  //
  // returns an array of Key and Route objects
  this.keysAndRoutes = function() {
    var knr = []
    for (var i in self.parts) {
      if (self.parts[i] instanceof Key || self.parts[i] instanceof Route) {
        knr.push(self.parts[i])
      }
    }
    return knr
  };

  // route.keys()
  // ---------------------
  // just the parts that are Keys
  //
  // returns an array of aforementioned Keys
  this.keys = function() {
    var keys = []
    for (var i in self.parts) {
      if (self.parts[i] instanceof Key) {
        keys.push(self.parts[i])
      }
    }
    return keys;
  };


  // route.parse( url, method )
  // --------------------------
  // parses a URL into a params object
  //
  //     route.parse( '/products/15/edit', 'GET' )
  //      => { controller:'products', action:'edit', id:15 }
  //
  // returns: a params hash || false (if the route doesn't match)
  //
  // **this is meant to be called by Router.first() && Router.all()**
  this.parse = function( urlParam, method ) {

    // parse the URL with the regex & step along with the parts,
    // assigning the vals from the url to the names of the keys as we go (potentially stoopid)

    // let's chop off the QS to make life easier
    var url = require('url').parse(urlParam)
    var path = url.pathname
    var params = {method:method}

    for (var key in self.params) { params[key] = self.params[key] }

    // if the method doesn't match, gtfo immediately
    if (typeof self.method != 'undefined' && self.method != params.method) return false

    /* TODO: implement substring checks for possible performance boost */

    // if the route doesn't match the regex, gtfo
    if (!self.test(path)) {
      return false
    }

    // parse the URL with the regex
    var parts = new RegExp('^' + self.regexString() + '$').exec(path)
    var j = 2; // index of the parts array, starts at 2 to bypass the entire match string & the entire match

    var keysAndRoutes = self.keysAndRoutes()

    for (var i in keysAndRoutes) {
      if (keysAndRoutes[i] instanceof Key) {
        if (keysAndRoutes[i].test(parts[j])) {
          params[keysAndRoutes[i].name] = parts[j]
        }
      } else if (keysAndRoutes[i] instanceof Route) {
        if (keysAndRoutes[i].test(parts[j])) {
          // parse the subroute
          var subparams = keysAndRoutes[i].parse(parts[j], method)
          mixin(params, subparams)
          // advance the parts pointer by the number of submatches
          j+= parts[j].match(keysAndRoutes[i].regexString()).length-2 || 0
        } else {
          j++;
        }
      }
      j++;
    }

    return params
  };

  // path parsing
  while (part = PARTS.exec(path)) {
    self.parts.push(part)
  }

  // have to do this in two passes due to RegExp execution limits
  for (var i in self.parts) {
    if (OGRP.test(self.parts[i])) { // optional group
      self.parts[i] = new Route(OGRP.exec(self.parts[i])[1], true)
      self.parts[i].optional = true

    } else if(KEY.test(self.parts[i])) { // key
      var keyname = KEY.exec(self.parts[i])[1]
      self.parts[i] = new Key(keyname)
    } else if(GLOB.test(self.parts[i])) { // glob
      var keyname = GLOB.exec(self.parts[i])[1]
      self.parts[i] = new Key(keyname, false, true)
    } else { // string
      self.parts[i] = String(self.parts[i])
    }
  }

  return self

}; // Route


exports.Route = Route