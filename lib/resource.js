var mixin         = require('./helpers').mixin
  , inflection    = require('inflection')

var Resource = exports.Resource = function( base, controller ){

  var controller_slug = inflection.underscore(inflection.pluralize(controller))

  this.routes = []

  // set up the actual routes for the resource
  this.routes.push(
    this.collection_route =
    base.get('/'+controller_slug+'(.:format)', 'GET').to(controller+'.index')
  , base.post('/'+controller_slug+'(.:format)', 'POST').to(controller+'.create')
  , base.get('/'+controller_slug+'/add(.:format)', 'GET').to(controller+'.add')
  , this.member_route =
    base.get('/'+controller_slug+'/:id(.:format)', 'GET').to(controller+'.show')
  , base.get('/'+controller_slug+'/:id/edit(.:format)', 'GET').to(controller+'.edit')
  , base.put('/'+controller_slug+'/:id(.:format)', 'PUT').to(controller+'.update')
  , base.del('/'+controller_slug+'/:id(.:format)', 'DELETE').to(controller+'.destroy')
  )
  this.collection_route.collection = true
  this.member_route.member = true
  return this
}

Resource.prototype.collection = function(cb){
  this.collection_route.nest(cb)
  return this // for chaining
}

Resource.prototype.member = function(cb){
  this.member_route.nest(cb)
  return this // for chaining
}

Resource.prototype.nest = function(cb){
  this.member_route.nest(cb)
  this.collection_route.nest(cb)
  return this // for chaining
}