mixin         = require('./helpers').mixin
inflection    = require('inflection')

class Resource
  constructor: ( base, controller )->

    controller_slug = inflection.underscore(inflection.pluralize(controller))

    # set up the actual routes for the resource
    @routes = [
      @collection_route = base.get("/#{controller_slug}(.:format)").to("#{controller}.index")
      , base.post("/#{controller_slug}(.:format)").to("#{controller}.create")
      , base.get("/#{controller_slug}/add(.:format)").to("#{controller}.add")
      , @member_route = base.get("/#{controller_slug}/:id(.:format)").to("#{controller}.show")
      , base.get("/#{controller_slug}/:id/edit(.:format)").to("#{controller}.edit")
      , base.put("/#{controller_slug}/:id(.:format)").to("#{controller}.update")
      , base.del("/#{controller_slug}/:id(.:format)").to("#{controller}.destroy")
    ]

    @collection_route.collection = true
    @member_route.member = true
    this

  collection: ( cb )->
    @collection_route.nest cb
    this # for chaining

  member: ( cb )->
    @member_route.nest cb
    this # for chaining

  nest: ( cb )->
    @member_route.nest cb
    @collection_route.nest cb
    this # for chaining


exports.Resource = Resource
