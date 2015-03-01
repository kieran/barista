{ Key, Glob }     = require './key'
{ Text }          = require './text'
{ Resource }      = require './resource'
{ kindof, mixin } = require './helpers'
inflection        = require 'inflection'

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
  constructor: ( router, path, method, @optional=false )->
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
      new_keys.push *path.match RegExp Key.regex.source, 'g' # find ALL

      # rename earlier keys
      for key in new_keys
        replKey = new RegExp ":(#{key.substring(1)}/?)"
        prefix = prefix.replace replKey, ":#{inflection.underscore inflection.singularize @params.controller}_$1"

      # create a new route instance
      nested_route = new Route router, prefix+path, method, @optional
      # add local default params
      nested_route.default_params = @default_params
      # apply local conditions
      nested_route.where @conditions if @conditions
      # return the new awesomeness
      return nested_route

    # uppercase the method name
    if typeof(method) == 'string'
      @method = method.toUpperCase()

    # base properties
    @params = {}
    @default_params = {}
    @parts = []
    @route_name = null
    @path = path
    # @router = router
    Object.defineProperty this, 'router', # exclude in enumerables
      enumerable: false
      configurable: false
      writable: false
      value: router

    @parts = Route.parse router, path, method, @optional

    # reset the path to the generated one (chop off any extra )'s )
    @path = @toString()

    unless @optional
      @router.routes.push this

    this


  # convenience methods
  # -------------------

  get: ( path )->   @match @router, path, 'GET'
  put: ( path )->   @match @router, path, 'PUT'
  post: ( path )->  @match @router, path, 'POST'
  patch: ( path )-> @match @router, path, 'PATCH'
  del: ( path )->   @match @router, path, 'DELETE'


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
    # a route regex is a composite of its parts' regexe(s|n)
    ret = ['(']
    ret.push part.regexString() for part in @parts
    ret.push ')'
    ret.push '?' if @optional
    ret.join ''

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
    @regex ?= RegExp "^#{@regexString()}(\\\?.*)?$"

    @regex.test string



  # route.to( endpoint [, default_params ] )
  # --------------------------------------
  # defines the endpoint & mixes in optional params
  #
  #     route.to( 'controller.action' )
  #
  #     route.to( 'controller.action', {lang:'en'} )
  #
  # returns the route for chaining
  #
  to: ( endpoint, default_params )->

    if !default_params && typeof endpoint != 'string'
      [ default_params, endpoint ] = [ endpoint, undefined ]

    mixin @default_params, default_params

    # TODO: make endpoint optional, since you can have the
    # controller & action in the URL utself,
    # even though that's a terrible idea...

    if endpoint
      unless 0 < endpoint.indexOf '.'
        throw new Error 'syntax should be in the form: controller.action'
      [ @params.controller, @params.action ] = endpoint.split '.'

    mixin @params, @default_params

    this # chainable


  # route.as( name )
  # ------------------
  # sets the route name - NAMED ROUTES ARE NOT CURRENTLY USED
  #
  #     route.as( 'login' )
  #     route.as( 'homepage' ) # etc...
  #
  # returns: the route for chaining
  #
  as: ( @route_name )->
    this # chainable

  # alias for as
  name: ( name )->
    console.log '''
      DEPRECATION NOTICE: this method has been renamed "as"
      and will be removed in a future version of Barista
    '''
    @as.apply this, arguments


  # route.where( conditions )
  # -------------------------
  # sets conditions that each url variable must match for the URL to be valid
  #
  #     route.where( { id:/\d+/, username:/\w+/ } )
  #
  # returns: the route for chaining
  #
  where: ( @conditions )->
    if kindof(@conditions) != 'object'
      throw new Error 'conditions must be an object'
    # recursively apply all conditions to sub-parts
    part.where? @conditions for part in @parts
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
      if part instanceof Key
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
    part for part in @parts when part instanceof Key || part instanceof Route

  # route.keys()
  # ---------------------
  # just the parts that are Keys (or globs)
  #
  # returns an array of aforementioned Keys
  #
  keys: ->
    part for part in @parts when part instanceof Key


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
    params =  method: method

    mixin params, @params

    # route HEAD requests to GET endpoints
    if is_head_req = params.method == 'HEAD'
      params.method = 'GET' # we'll put it back when we're done

    # if the method doesn't match, gtfo immediately
    return false if @method? && params.method? && @method != params.method

    # assign the route's method if there isn't one
    params.method ?= @method

    # TODO: implement substring checks for possible performance boost

    # if the route doesn't match the regex, gtfo
    return false unless @test path

    # parse the URL with the regex
    # first 2 elements are shit, chop 'em
    parts = new RegExp("^#{@regexString()}$").exec(path)[2..]
    pairings = []

    # loop 1 (forwards) - collect the key/route -> part pairings for loop 2
    j = 0
    for segm in @keysAndRoutes()
      part = parts[j]

      # stash the pairings for loop 2 if this part matches segment
      pairings.push [ segm, part ] if segm.test part

      # routes must advance the part iterator by the number of parts matched in the segment
      j+= segm.regex.exec(part||'')[2..].length || 1


    # loop 2 (backwards) - parse the key/route -> part pairings (backards so later optional matches are preferred)
    # i.e. /path(.:format)/something(.:format) would keep the last format segment, while discarding the first
    # this makes life easier for nesting route definitions
    for [ segm, part ] in pairings by -1
      # actually mixin the params
      if segm instanceof Key
        params[segm.name] = part
      else if segm instanceof Route
        mixin params, segm.parse part, method

    # replace HEAD method?
    params.method = 'HEAD' if is_head_req

    params



  nest: ( cb )->
    unless typeof cb == 'function'
      throw new Error 'route.nest() requires a callback function'
    cb.call this
    this # for chaining



  # route.toString()
  # ----------------
  # returns the original route definition
  #
  toString: ->
    defn = (part.toString() for part in @parts).join ''
    return "(#{ defn })" if @optional
    defn

  # Route.parse( router, string, method, optional=false )
  # =====================================================
  # parses a route definition into a swiss army bazooka
  #
  #     route = Route.parse(router, '/:controller/:action/:id(.:format)')
  #     route = Route.parse(router, '/:controller/:action(/:id)(.:format)', 'GET')
  #     route = Route.parse(router, '/:controller/:action(/:id)(.:format)',
  #     route = Route.parse(router, '/:controller/:action/:id(.:format)', 'GET')
  #
  # Pretty familiar to anyone who's used Merb/Rails - called by Router.match()
  #

  @parse = ( router, string, method, optional=false )->
    parts = []

    # parse it char by char, baby
    i   = 0
    len = string.length

    # for char, i in string
    while i < len
      char = string[i]
      rest = string[i..]

      # special consideration for Ogrp starts
      if char == '(' && i == 0
        i++
        continue # skip this char, since it's not strictly part of the route definition

      # the route definition is over, return what we have
      if char == ')'
        return parts

      if char == ':' && string[i+1] != ':'
        parts.push part = Key.parse rest
      else if char == '*'
        parts.push part = Glob.parse rest
      else if char == '('
        parts.push part = new Route router, rest, method, true
      else
        parts.push part = Text.parse rest

      i += part.toString().length

    parts
