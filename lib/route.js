var Key           = require('./key').Key
  , Resource      = require('./resource').Resource
  , regExpEscape  = require('./helpers').regExpEscape
  , mixin         = require('./helpers').mixin
  , kindof        = require('./helpers').kindof
  , inflection    = require('inflection')

// new Route( router, path [, method] )
// =================
// turns strings into magical ponies that come when you call them
//
//     route = new Route(router, '/:controller/:action/:id(.:format)')
//     route = new Route(router, '/:controller/:action(/:id)(.:format)', 'GET')
//     route = new Route(router, '/:controller/:action(/:id)(.:format)',
//     route = new Route(router, '/:controller/:action/:id(.:format)', 'GET')
//
// Pretty familiar to anyone who's used Merb/Rails - called by Router.match()
//
var Route = exports.Route = function( router, path, method ) {
  if ( router && path ) this.match.apply( this, arguments )
  return this
}


// !x! regexen crossing !x!
// matches keys
Route.prototype.KEY = /:([a-zA-Z_][\w\-]*)/
// matches globs
Route.prototype.GLOB = /\*([a-zA-Z_][\w\-\/]*)/
// optional group (the part in parens)
Route.prototype.OGRP = /\(([^)]+)\)/
// breaks a string into atomic parts: ogrps, keys, then everything else
Route.prototype.PARTS = /\([^)]+\)|:[a-zA-Z_][\w\-]*|\*[a-zA-Z_][\w\-]*|[\w\-_\\\/\.]+/g


// route.match()
// -------------------
//
// the actual route builder function, mostly called by `new Route`
//
Route.prototype.match = function( router, path, method, optional ){

  if ( typeof path != 'string' ) throw new Error('path must be a string')

  // is this a nested path?
  if ( this.path != undefined ) {
    var prefix = this.path

    // get a list of key names in the new segment
    var new_keys = (this.collection || this.member) ? [':id'] : [] // force id to be renamed for resources
    Array.prototype.push.apply(new_keys, path.match(RegExp(this.KEY.source,'g')) ) // find all

    // rename earlier keys
    for (var i=0; i<new_keys.length; i++){
      var replKey = new RegExp(':('+new_keys[i].substring(1)+'/?)')
      prefix = prefix.replace(replKey,":"+inflection.underscore(inflection.singularize(this.params['controller']))+"_$1")
    }

    // return the new awesomeness
    return (new Route( router, prefix+path, method ))
  }

  // is this a nested, optional url segment like (.:format)
  this.optional = optional == true

  // uppercase the method name
  if ( typeof(method) == 'string' ) this.method = method.toUpperCase()

  // base properties
  this.router = router
  this.params = {}
  this.parts = []
  this.route_name = null
  this.path = path

  // path parsing
  var part;
  while (part = this.PARTS.exec(path)) {
    this.parts.push(part)
  }

  // have to do this in two passes due to RegExp execution limits
  for (var i in this.parts) {
    if (this.OGRP.test(this.parts[i])) { // optional group
      this.parts[i] = new Route(this.router, this.OGRP.exec(this.parts[i])[1], true, true)
    } else if(this.KEY.test(this.parts[i])) { // key
      var keyname = this.KEY.exec(this.parts[i])[1]
      this.parts[i] = new Key(keyname)
    } else if(this.GLOB.test(this.parts[i])) { // glob
      var keyname = this.GLOB.exec(this.parts[i])[1]
      this.parts[i] = new Key(keyname, false, true)
    } else { // string
      this.parts[i] = String(this.parts[i])
    }
  }

  if (!this.optional) this.router.routes.push(this)

  return this

}; // Route



// convenience methods
// -------------------

  // ### route.get( path )
  // equivalent to
  //
  //     route.match( path, 'GET' )
  //
  Route.prototype.get = function( path ){
    return this.match(this.router, path, 'GET')
  }

  // ### route.put( path )
  // equivalent to
  //
  //     route.match( path, 'PUT' )
  //
  Route.prototype.put = function( path ){
    return this.match(this.router, path, 'PUT')
  }

  // ### route.post( path )
  // equivalent to
  //
  //     route.match( path, 'POST' )
  //
  Route.prototype.post = function( path ){
    return this.match(this.router, path, 'POST')
  }

  // ### route.del( path )
  // equivalent to
  //
  //     route.match( path, 'DELETE' )
  //
  Route.prototype.del = function( path ){
    return this.match(this.router, path, 'DELETE')
  }


// route.resource( controller )
// -----------------------------
// generates standard resource routes for a controller name
//
//     route.resource('products')
//
// returns a Resource object
//
Route.prototype.resource = function( controller ) {
  var resource = new Resource( this, controller )
  return resource
};


// route.regexString()
// -------------------
//
// returns a composite regex string of all route parts
//
Route.prototype.regexString = function() {
  var ret = ''
  // a route regex is a composite of its parts' regexe(s|n)
  for (var i in this.parts) {
    var part = this.parts[i]
    ret += part.regexString ? part.regexString() : regExpEscape(part)
  }
  return '('+ret+')'+(this.optional ? '?' : '')
};


// route.test( string )
// -----------
// builds & tests on a full regex of the entire path
//
//     route.test( '/products/19/edit' )
//      => true
//
// returns true/false depending on whether the url matches
//
Route.prototype.test = function( string ) {
  // with caching
  if(!this.regex) this.regex = RegExp('^' +  this.regexString() + '(\\\?.*)?$')
  return this.regex.test(string)

  // without caching
  // return RegExp('^' +  this.regexString() + '(\\\?.*)?$').test(string)
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
//
Route.prototype.to = function( endpoint, extra_params ) {

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
    if( kindof(endpoint) == 'array' && endpoint.length != 2 ) throw new Error('syntax should be in the form: controller.action')
    this.params.controller = endpoint[0]
    this.params.action = endpoint[1]
  }

  extra_params = kindof(extra_params) == 'object' ? extra_params : {}
  mixin(this.params, extra_params)

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
//
Route.prototype.name = function( name ) {
  this.route_name = name
  return this // chainable
};


// route.where( conditions )
// ---------------------
// sets conditions that each url variable must match for the URL to be valid
//
//     route.where( { id:/\d+/, username:/\w+/ } )
//
// returns: the route for chaining
//
Route.prototype.where = function( conditions ) {

  if ( kindof(conditions) != 'object' ) throw new Error('conditions must be an object')

  for (var i in this.parts) {
    if (this.parts[i] instanceof Key || this.parts[i] instanceof Route) {
      // recursively apply all conditions to sub-parts
      this.parts[i].where(conditions)
    }
  }

  return this // chainable
};


// route.stringify( params )
// -------------------------
// builds a string url for this Route from a params object
//
// returns: [ "url", [leftover params] ]
//
// **this is meant to be called & modified by router.url()**
//
Route.prototype.stringify = function( params ) {
  var url = [] // urls start life as an array to enble a second pass

  for (var i in this.parts) {
    var part = this.parts[i]
    if (part instanceof Key) {
      if (typeof(params[part.name]) != 'undefined' &&
          part.regex.test(params[part.name])) {
        // there's a param named this && the param matches the key's regex
        url.push(part.url(params[part.name])); // push it onto the stack
        delete params[part.name] // and remove from list of params
      } else if (this.optional) {
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

  // second pass, resolve optional parts (backwards, so later optionals are resolved first)
  for (var i=url.length-1; i>=0; i--) {
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

  for (var i in this.params) {
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
//
Route.prototype.keysAndRoutes = function() {
  var knr = []
  for (var i in this.parts) {
    if (this.parts[i] instanceof Key || this.parts[i] instanceof Route) {
      knr.push(this.parts[i])
    }
  }
  return knr
};

// route.keys()
// ---------------------
// just the parts that are Keys
//
// returns an array of aforementioned Keys
//
Route.prototype.keys = function() {
  var keys = []
  for (var i in this.parts) {
    if (this.parts[i] instanceof Key) {
      keys.push(this.parts[i])
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
//
Route.prototype.parse = function( urlParam, method ) {

  // parse the URL with the regex & step along with the parts,
  // assigning the vals from the url to the names of the keys as we go (potentially stoopid)

  // let's chop off the QS to make life easier
  var url = require('url').parse(urlParam)
    , path = url.pathname
    , params = {method:method}

  mixin( params, this.params )

  // route HEAD requests to GET endpoints
  var HEAD = params.method == 'HEAD'
  if ( HEAD ) params.method = 'GET' // we'll put it back when we're done

  // if the method doesn't match, gtfo immediately
  if (typeof this.method != 'undefined' && typeof params.method != 'undefined' && this.method != params.method) return false

  // assign the route's method if there isn't one
  if (typeof params.method == 'undefined') params.method = this.method

  /* TODO: implement substring checks for possible performance boost */

  // if the route doesn't match the regex, gtfo
  if (!this.test(path)) {
    return false
  }

  // parse the URL with the regex
  var parts = new RegExp('^' + this.regexString() + '$').exec(path).slice(2) // slice(2) returns just the array of matches from the regexp object
    , keysAndRoutes = this.keysAndRoutes()
    , pairings = []

  // loop 1 (forwards) - collect the key/route -> part pairings for loop 2
  for (var i=0, j=0; i<keysAndRoutes.length; i++, j++) {
    var part = parts[j]
      , segm = keysAndRoutes[i]

    // if this part doesnt match the segment, move on
    if ( !segm.test(part) ) { j++; continue }

    // stash the pairings for loop 2
    pairings.push( [ segm, part ] )

    // routes must advance the part iterator by the number of parts matched in the segment
    if (segm instanceof Route) j+= part.match(segm.regexString()).slice(2).length || 0
  }

  // loop 2 (backwards) - parse the key/route -> part pairings (backards so later optional matches are preferred)
  // i.e. /path(.:format)/something(.:format) would keep the last format segment, while discarding the first
  // this makes life easier for nesting route definitions
  for (var i=pairings.length-1; i>=0; i--) {
    var part = pairings[i][1]
      , segm = pairings[i][0]

    // actually mixin the params
    if (segm instanceof Key ) {
      params[segm.name] = part
    } else if ( segm instanceof Route ) {
      mixin(params, segm.parse(part, method) )
    }
  }

  // replace HEAD method?
  if ( HEAD ) params.method = 'HEAD'

  return params
}


Route.prototype.nest = function(cb){
  if ( typeof cb != 'function' ) throw new Error('route.nest() requires a callback function')
  cb.call( this )
  return this // for chaining
}


Route.prototype.toString = function(){

  var path        = this.path
    , method      = this.method || 'ALL'
    , controller  = this.params.controller
    , action      = this.params.action

  // right-pads strings
  function rpad(str,len){
    var ret = new Array(len+1) // +1 for fenceposting
    ret.splice(0, str.length, str)
    return ret.join(' ')
  }

  return [
    rpad(method,8),
    rpad(path,50),
    [this.params.controller, this.params.action].join('.')
  ].join('')
}