{ Route }     = require './route'
{ Resource }  = require './resource'
qstring       = require 'querystring'

exports.Router =
class Router
  constructor: ->
    @methods =  [ 'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'OPTIONS' ]
    @routes =   []

  # router.match( path [, method] )
  # -------------------------------
  #
  #     router.match('/:controller/:action(/:id)(.:format)', 'GET')
  #      .to(......)
  #
  # path is mandatory (duh)
  # method is optional, routes without a method will apply in all cases
  #
  # returns the route (for chaining)
  #
  match: ( path, method )->
    # upcase the method
    if typeof(method) == 'string'
      method = method.toUpperCase()

    # upcase the method
    if method? && !@methods_regexp().test method
      throw new Error "method must be one of: #{ @methods.join ', ' }"

    route = new Route this, path, method

  # ### router.get( path )
  # equivalent to
  #
  #     router.match( path, 'GET' )
  #
  get: ( path )->
    @match path, 'GET'

  # ### router.options( path )
  # equivalent to
  #
  #     router.match( path, 'OPTIONS' )
  #
  options: ( path )->
    @match path, 'OPTIONS'

  # ### router.put( path )
  # equivalent to
  #
  #     router.match( path, 'PUT' )
  #
  put: ( path )->
    @match path, 'PUT'

  # ### router.post( path )
  # equivalent to
  #
  #     router.match( path, 'POST' )
  #
  post: ( path )->
    @match path, 'POST'

  # ### router.del( path )
  # equivalent to
  #
  #     router.match( path, 'DEL' )
  #
  del: ( path )->
    @match path, 'DELETE'

  # router.resource( controller )
  # -----------------------------
  # generates standard resource routes for a controller name
  #
  #     router.resource('products')
  #
  # returns a Resource object
  #
  resource: ( controller )->
    new Resource this, controller

  # // router.first( path, method, callback )
  # ----------------------------
  # find the first route that match the path & method
  #
  #     router.first('/products/5', 'GET')
  #     => { controller: 'products', action: 'show', id: 5, method: 'GET' }
  #
  # find & return a params hash from the first route that matches. If there's no match, this will return false
  #
  # If the options callback function is provided, it will be fired like so:
  #
  #     callback( error, params )
  #
  first: ( path, method, cb )->
    params = false

    for route in @routes
      # attempt the parse
      params = route.parse(path, method)

      if params
        # fire the callback if given
        if typeof cb == 'function'
          cb undefined, params
        # may as well return this
        return params

    if typeof cb == 'function'
      cb 'No matching routes found'
    false


  # router.all( path [, method] )
  # --------------------------
  # find & return a params hash from ALL routes that match
  #
  #     router.all( '/products/5' )
  #
  #       => [
  #         { controller: 'products', action: 'show', id: 5, method: 'GET' },
  #         { controller: 'products', action: 'update', id: 5, method: 'PUT' },
  #         { controller: 'products', action: 'destroy', id: 5, method: 'DELETE' },
  #       ]
  #
  # if there ares no matches, returns an empty array
  #
  all: ( path, method )->
    ret = []
    params = false

    for route in @routes
      params = route.parse.apply route, arguments
      if params
        ret.push params
    ret



  # // router.url( params[, add_querystring=false] )
  # --------------------------------------------
  # generates a URL from a params hash
  #
  #     router.url( {
  #       controller: 'products',
  #       action: 'show',
  #       id: 5
  #     } )
  #     => '/products/5'
  #
  #     router.url( {
  #       controller: 'products',
  #       action: 'show',
  #       id: 5,
  #       format: 'json'
  #     } )
  #     => '/products/5.json'
  #
  #     router.url({
  #       controller: 'products',
  #       action: 'show',
  #       id: 5,
  #       format: 'json',
  #       love: 'cheese'
  #     }, true )
  #     => '/products/5.json?love=cheese'
  #
  # returns false if there are no suitable routes
  #
  url: ( params, add_querystring )->
    url = false

    # iterate through the existing routes until a suitable match is found
    for route in @routes
      # do the controller & acton match?
      continue if route.params.controller? && route.params.controller != params.controller
      continue if route.params.action? && route.params.action != params.action

      break if url = route.stringify params

    return false unless url# no love? return false
    qs = qstring.stringify url[1] # build the possibly empty query string

    if add_querystring && qs.length > 0
      return url[0] + '?' + qs # if there is a query string...

    url[0] # just return the url


  # router.remove( name )
  # ------------------------
  #
  # Removes previously created routes by name
  #
  # The route must be a named route, and the name is passed in.
  #
  # returns: Nothing
  #
  remove: ( name )->
    @routes = @routes.filter (el)->
      el.route_name != name

  # router.defer( testfn() )
  # ------------------------
  #
  #     router.defer( test( path, method ) )
  #
  # test should be a function that examines non-standard URLs
  #
  # path and method will be passed in - expects a params hash back OR false on a non-match
  #
  # returns: DeferredRoute (for... reference? I dunno.)
  #
  # **THIS IS CURRENTLY COMPLETELY UNTESTED. IT MIGHT NOT EVEN WORK. SERIOUSLY.**
  #
  defer: ( fn )->
    if typeof(fn) != 'function'
      throw new Error 'Router.defer requires a function as the only argument'

    route = new Route this, 'deferred'
    route.parse = fn # add the custom parser
    delete route.test # = function(){return false};
    delete route.stringify # = function(){ throw new Error('Deferred routes are NOT generatable')};
    @routes.push route
    route

  # router.toString
  # ---------------
  #
  # renders a textual description of the router for inpection
  #
  toString: ->
    @routes.map ((rt)->
      rt.toString()
    ).join '\n'

  # methods_regexp
  # --------------
  #
  # builds a regexp out of the methods for method validation (used once, remove?)
  #
  methods_regexp: ->
    RegExp "^(#{ @methods.join '|' })$",'i'
