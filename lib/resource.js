var snakeize  = require('./helpers').snakeize
  , mixin     = require('./helpers').mixin

var Resource = exports.Resource = function( base, controller ){

  var controller_slug = this.name = snakeize(controller)

  this.routes = []

  // set up the actual routes for the resource
  this.routes.push(
    this.collection_route =
    base.get('/'+controller_slug+'(.:format)', 'GET').to(controller+'.index')
  , base.get('/'+controller_slug+'/add(.:format)', 'GET').to(controller+'.add')
  , this.member_route =
    base.get('/'+controller_slug+'/:id(.:format)', 'GET').to(controller+'.show')
  , base.get('/'+controller_slug+'/:id/edit(.:format)', 'GET').to(controller+'.edit')
  , base.post('/'+controller_slug+'(.:format)', 'POST').to(controller+'.create')
  , base.put('/'+controller_slug+'/:id(.:format)', 'PUT').to(controller+'.update')
  , base.del('/'+controller_slug+'/:id(.:format)', 'DELETE').to(controller+'.destroy')
  )

  return this
}

Resource.prototype.collection = function(cb){
  if ( typeof cb != 'function' ) throw 'resource.collection() requires a callback function'
  cb.call( this.collection_route )
  return this // for chaining
}

Resource.prototype.member = function(cb){
  if ( typeof cb != 'function' ) throw 'resource.member() requires a callback function'
  cb.call( this.member_route )
  return this // for chaining
}