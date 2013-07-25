{ Key, Glob } = require './key'
{ Text }      = require './text'
{ Resource }  = require './resource'
inflection    = require 'inflection'

# !x! regexen crossing !x!
# matches keys
KEY   = /:([a-zA-Z_][\w\-]*)/
# matches globs
GLOB  = /\*([a-zA-Z_][\w\-\/]*)/
# optional group (the part in parens)
OGRP  = /\(([^)]+)\)/

PARTS = ///
        \([^)]+\)             # OGRPS
      |  :[a-zA-Z_][\w\-]*    # KEYS
      | \*[a-zA-Z_][\w\-]*    # GLOBS
      | [\w\-_\\\/\.]+        # TEXT
///g

# new Route( router, path [, method] )
# ====================================
# turns strings into magical ponies that come when you call them
#
#     route = new Route(router, '/:controller/:action/:id(.:format)')
#     route = new Route(router, '/:controller/:action(/:id)(.:format)', 'GET')
#     route = new Route(router, '/:controller/:action(/:id)(.:format)',
#     route = new Route(router, '/:controller/:action/:id(.:format)', 'GET')
#
# Pretty familiar to anyone who's used Merb/Rails - called by Router.match()
#
exports.Route =
class Route
  constructor: ( router, path, method )->
    if router && path
      @match.apply this, arguments


  # route.match()
  # -------------------
  #
  # the actual route builder function, mostly called by `new Route`
  #
  match: ( router, path, method, @optional=false )->

    if typeof path != 'string'
      throw new Error 'path must be a string'

    # is this a nested path?
    if @path?
      prefix = @path

      # get a list of key names in the new segment TODO: globs
      new_keys = []
      new_keys.push ':id' if @collection || @member # force id to be renamed for resources
      Array::push.apply new_keys, path.match RegExp(KEY.source, 'g') # find ALL

      # rename earlier keys
      for key in new_keys
        replKey = new RegExp ":(#{key.substring(1)}/?)"
        prefix = prefix.replace replKey, ":#{inflection.underscore inflection.singularize @params.controller}_$1"

      # return the new awesomeness
      return new Route router, prefix+path, method

    # uppercase the method name
    if typeof(method) == 'string'
      @method = method.toUpperCase()

    # base properties
    @params = {}
    @parts = []
    @route_name = null
    @path = path
    # @router = router
    Object.defineProperty this, "router", # exclude in enumerables
      enumerable: false
      configurable: false
      writable: false
      value: router

    # path parsing
    while part = PARTS.exec path
      @parts.push part

    # have to do this in two passes due to RegExp execution limits
    for part, i in @parts
      if OGRP.test part # optional group
        @parts[i] = new Route @router, OGRP.exec(part)[1], true, true
      else if KEY.test part # key
        @parts[i] = new Key KEY.exec(part)[1]
      else if GLOB.test part # glob
        @parts[i] = new Glob GLOB.exec(part)[1]
      else # string
        @parts[i] = String part

    unless @optional
      @router.routes.push this

    this



  # convenience methods
  # -------------------

  # ### route.get( path )
  # equivalent to
  #
  #     route.match( path, 'GET' )
  #
  get: ( path )->
    @match @router, path, 'GET'

  # ### route.put( path )
  # equivalent to
  #
  #     route.match( path, 'PUT' )
  #
  put: ( path )->
    @match @router, path, 'PUT'

  # ### route.post( path )
  # equivalent to
  #
  #     route.match( path, 'POST' )
  #
  post: ( path )->
    @match @router, path, 'POST'

  # ### route.del( path )
  # equivalent to
  #
  #     route.match( path, 'DELETE' )
  #
  del: ( path )->
    @match @router, path, 'DELETE'


  # route.resource( controller )
  # -----------------------------
  # generates standard resource routes for a controller name
  #
  #     route.resource('products')
  #
  # returns a Resource object
  #
  resource: ( controller )->
    new Resource this, controller


  # route.regexString()
  # -------------------
  #
  # returns a composite regex string of all route parts
  #
  regexString: ->
    ret = ''
    # a route regex is a composite of its parts' regexe(s|n)
    for part in @parts
      ret += if part.regexString then part.regexString() else regExpEscape part

    "(#{ret})#{if @optional then '?' else ''}"


  # route.test( string )
  # -----------
  # builds & tests on a full regex of the entire path
  #
  #     route.test( '/products/19/edit' )
  #      => true
  #
  # returns true/false depending on whether the url matches
  #
  test: ( string )->
    # cache the regex string
    @regex = RegExp "^#{@regexString()}(\\\?.*)?$" unless @regex

    @regex.test string



  # route.to( endpoint [, extra_params ] )
  # --------------------------------------
  # defines the endpoint & mixes in optional params
  #
  #     route.to( 'controller.action' )
  #
  #     route.to( 'controller.action', {lang:'en'} )
  #
  # returns the route for chaining
  #
  to: ( endpoint, extra_params )->

    if !extra_params && typeof endpoint != 'string'
      extra_params = endpoint
      endpoint = undefined

    # TODO: make endpoint optional, since you can have the
    # controller & action in the URL utself,
    # even though that's a terrible idea...

    if endpoint
      endpoint = endpoint.split '.'
      if kindof(endpoint) == 'array' && endpoint.length != 2
        throw new Error 'syntax should be in the form: controller.action'
      @params.controller = endpoint[0]
      @params.action = endpoint[1]

    extra_params = {} unless kindof(extra_params) == 'object'

    mixin @params, extra_params

    this # chainable


  # route.name( name )
  # ------------------
  # just sets the route name - NAMED ROUTES ARE NOT CURRENTLY USED
  #
  #     route.name( 'login' )
  #     route.name( 'homepage' ) # etc...
  #
  # returns: the route for chaining
  #
  name: ( name )->
    @route_name = name
    this # chainable


  # route.where( conditions )
  # -------------------------
  # sets conditions that each url variable must match for the URL to be valid
  #
  #     route.where( { id:/\d+/, username:/\w+/ } )
  #
  # returns: the route for chaining
  #
  where: ( conditions )->
    if kindof(conditions) != 'object'
      throw new Error 'conditions must be an object'

    for part in @parts
      unless typeof part == 'string'
        # recursively apply all conditions to sub-parts
        part.where conditions

    this # chainable


  # route.stringify( params )
  # -------------------------
  # builds a string url for this Route from a params object
  #
  # returns: [ "url", [leftover params] ]
  #
  # **this is meant to be called & modified by router.url()**
  #
  stringify: ( params )->
    url = [] # urls start life as an array to enable a second pass

    for part in @parts
      if part instanceof Key || part instanceof Glob
        if params[part.name]? && part.regex.test params[part.name]
          # there's a param named this && the param matches the key's regex
          url.push part.url params[part.name] # push it onto the stack
          delete params[part.name]
          # `delete params[part.name]` # and remove from list of params
        else if @optional
          # (sub)route doesn't match, move on
          return false
      else if part instanceof Route
        # sub-routes must be handled in the next pass
        # to avoid leftover param duplication
        url.push part
      else # string
        url.push part

    # second pass, resolve optional parts (backwards, so later optionals are resolved first)
    #for i=url.length-1; i>=0; i--
    for part, i in url by -1
      if part instanceof Route
        part = part.stringify params # recursion is your friend
        # it resolved to a url fragment!
        if part
          params = part[1] # replace leftover params hash with the new, smaller leftover params hash
          url[i] = part = part[0] # leave only the string for joining
        else
          delete url[i] # get rid of these shits

    for key, val of @params
      # remove from leftovers, they're implied in the to() portion of the route
      delete params[key]

    [ url.join(''), params ]


  # route.keysAndRoutes()
  # ---------------------
  # just the parts that aren't strings. basically
  #
  # returns an array of Key and Route objects
  #
  keysAndRoutes: ->
    @parts.filter (part)->
      part instanceof Key || part instanceof Glob || part instanceof Route

  # route.keys()
  # ---------------------
  # just the parts that are Keys (or globs)
  #
  # returns an array of aforementioned Keys
  #
  keys: ->
    @parts.filter (part)->
      part instanceof Key || part instanceof Glob


  # route.parse( url, method )
  # --------------------------
  # parses a URL into a params object
  #
  #     route.parse( '/products/15/edit', 'GET' )
  #      => { controller:'products', action:'edit', id:15 }
  #
  # returns: a params hash || false (if the route doesn't match)
  #
  # **this is meant to be called by Router.first() && Router.all()**
  #
  parse: ( urlParam, method )->

    # parse the URL with the regex & step along with the parts,
    # assigning the vals from the url to the names of the keys as we go (potentially stoopid)

    # let's chop off the QS to make life easier
    url =     require('url').parse urlParam # TODO: fix this
    path =    decodeURI url.pathname
    params =  { method: method }

    mixin params, @params

    # route HEAD requests to GET endpoints
    head = params.method == 'HEAD'
    if head
      params.method = 'GET' # we'll put it back when we're done

    # if the method doesn't match, gtfo immediately
    if @method? && params.method?
      if @method != params.method
        return false

    # assign the route's method if there isn't one
    params.method ?= @method

    # TODO: implement substring checks for possible performance boost

    # if the route doesn't match the regex, gtfo
    return false unless @test path

    # parse the URL with the regex
    # slice(2) returns just the array of matches from the regexp object
    parts = new RegExp("^#{@regexString()}$").exec(path).slice(2)
    keysAndRoutes = @keysAndRoutes()
    pairings = []

    # loop 1 (forwards) - collect the key/route -> part pairings for loop 2
    `
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
    `
    # loop 2 (backwards) - parse the key/route -> part pairings (backards so later optional matches are preferred)
    # i.e. /path(.:format)/something(.:format) would keep the last format segment, while discarding the first
    # this makes life easier for nesting route definitions
    for pair in pairings by -1
      part = pair[1]
      segm = pair[0]

      # actually mixin the params
      if segm instanceof Key || segm instanceof Glob
        params[segm.name] = part
      else if segm instanceof Route
        mixin params, segm.parse(part, method)

    # replace HEAD method?
    params.method = 'HEAD' if head

    params



  nest: ( cb )->
    if typeof cb != 'function'
      throw new Error 'route.nest() requires a callback function'
    cb.call this
    this # for chaining



  toString: ->

    # right-pads strings
    rpad = (str,len)->
      ret = new Array len+1 # +1 for fenceposting
      ret.splice 0, str.length, str
      ret.join ' '

    [
      rpad( @method || 'ALL',8 ),
      rpad( @path, 50 ),
      [ @params.controller, @params.action ].join('.')
    ].join ''



# Helper methods
# =============================================

# deep object mixer
mixin = ( ret, mixins... )->
  for obj in mixins
    for own key, val of obj
      if kindof(val) == 'object'
        ret[key] = mixin {}, val
      else
        ret[key] = val
  ret

# better than typeof
kindof = ( o )->
  switch
    when typeof o != "object"     then typeof o
    when o == null                then "null"
    when o.constructor == Array   then "array"
    when o.constructor == Date    then "date"
    when o.constructor == RegExp  then "regex"
    else "object"

# escape a string for literal embedding in a regexp
regExpEscape = do ->
  specials = [ '/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\' ]
  sRE = new RegExp "(\\#{ specials.join '|\\' })", 'g'
  ( text )-> text.replace sRE, '\\$1'
