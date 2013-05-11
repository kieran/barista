inflection    = require 'inflection'

exports.Resource =
class Resource
  constructor: ( base, controller )->

    slug = inflection.underscore(inflection.pluralize(controller))

    # set up the actual routes for the resource
    @routes = [
        base.get("/#{slug}(.:format)")           .to("#{controller}.index")
      , base.post("/#{slug}(.:format)")          .to("#{controller}.create")
      , base.get("/#{slug}/add(.:format)")       .to("#{controller}.add")
      , base.get("/#{slug}/:id(.:format)")       .to("#{controller}.show")
      , base.get("/#{slug}/:id/edit(.:format)")  .to("#{controller}.edit")
      , base.put("/#{slug}/:id(.:format)")       .to("#{controller}.update")
      , base.del("/#{slug}/:id(.:format)")       .to("#{controller}.destroy")
    ]

    @collection_route = @routes[0]
    @member_route = @routes[3]

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
