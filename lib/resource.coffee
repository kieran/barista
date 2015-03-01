{ kindof, mixin } = require './helpers'
inflection        = require 'inflection'

exports.Resource =
class Resource
  constructor: ( base, controller )->

    plural = inflection.underscore inflection.pluralize controller
    singular = inflection.underscore inflection.singularize controller

    # set up the actual routes for the resource
    @routes = [
      base.get("/#{plural}(.:format)")
      .to("#{controller}.index")
      .as(
        if base.collection || base.member
          nomenclate base.route_name, plural
        else
          nomenclate plural
      )

      base.post("/#{plural}(.:format)")
      .to("#{controller}.create")

      base.get("/#{plural}/add(.:format)")
      .to("#{controller}.add")
      .as(
        if base.collection || base.member
          nomenclate 'add', base.route_name, singular
        else
          nomenclate 'add', singular
      )

      base.get("/#{plural}/:id(.:format)")
      .to("#{controller}.show")
      .as(
        if base.collection || base.member
          nomenclate base.route_name, singular
        else
          nomenclate singular
      )

      base.get("/#{plural}/:id/edit(.:format)")
      .to("#{controller}.edit")
      .as(
        if base.collection || base.member
          nomenclate 'edit', base.route_name, singular
        else
          nomenclate 'edit', singular
      )

      base.put("/#{plural}/:id(.:format)")
      .to("#{controller}.update")

      base.del("/#{plural}/:id(.:format)")
      .to("#{controller}.destroy")
    ]

    @collection_route = @routes[0]
    @member_route = @routes[3]

    @collection_route.collection = true
    @member_route.member = true
    this

  where: ( conditions )->
    if kindof(conditions) != 'object'
      throw new Error 'conditions must be an object'
    # recursively apply all conditions to sub-parts
    route.where? conditions for route in @routes
    this # chainable

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


# Helper methods
# =============================================

# better than typeof
kindof = ( o )->
  switch
    when typeof o != "object"     then typeof o
    when o == null                then "null"
    when o.constructor == Array   then "array"
    when o.constructor == Date    then "date"
    when o.constructor == RegExp  then "regex"
    else "object"

# builds route names
# TODO: clean this up
nomenclate = ->
  args = Array::slice.call arguments
  args.join('_') unless args.filter((a)->!a?).length
