# new Key( name, optional )
# =================================
# those variable thingies
#
#     key = new Key('name')
#     key = new Key('name', true)
#
exports.Key =
class Key
  constructor: ( @name, @optional )->

    @regex = /[\w\-\s]+/ # default url-friendly regex

    # special defaults for controllers & actions, which will always be function-name-safe
    if @name == 'controller' || @name == 'action'
      @regex = /[a-zA-Z_][\w\-]*/


  # key.regexString()
  # -----------------
  # makes a regex string of the key - used by key.test()
  #
  # returns a string of this keys regex
  #
  regexString: ->
    ret = String(@regex).replace(/^\//, '').replace /\/[gis]?$/, ''
    "(#{ret})#{if @optional then '?' else ''}"


  # key.test( string )
  # -----------------
  # validates a string using the key's regex pattern
  #
  # returns true/false if the string matches
  #
  test: ( string )->
    new RegExp("^#{@regexString()}$").test(string)


  # key.url( string )
  # -----------------
  # returns a string for building the url
  # if it matches the key conditions
  #
  url: ( string )->
    if @test(string) then string else false


  # key.where( conditions )
  # -----------------------
  # adds conditions that the key must match
  #
  # returns the key... because it can?
  #
  where: ( conditions )->

    condition = conditions[@name]

    if condition instanceof RegExp
      @regex = condition #  e.g. /\d+/

    if condition instanceof String
      @regex = new RegExp condition.replace(/^\//, '').replace /\/[gis]?$/, '' #  e.g. "\d+"

    #  an array of allowed values, e.g. ['stop','play','pause']
    if condition instanceof Array
      @regex = new RegExp condition.map( (cond)->
        cond.toString().replace(/^\//, '').replace /\/[gis]?$/, ''
      ).join '|'

    this # chainable


  # key.toString()
  # --------------
  # returns a unique id that can be compared to other parts
  #
  toString: ->
    "key-#{@name}"


# new Glob( name, optional )
# =================================
# globs are just greedy keys
#
#     glob = new Glob('name')
#     glob = new Glob('name', true)
#
exports.Glob =
class Glob extends Key
  constructor: ( @name, @optional )->

    @regex = /[\w\-\/\s]+?/ # default url-friendly regex

    # special defaults for controllers & actions, which will always be function-name-safe
    if @name == 'controller' || @name == 'action'
      @regex = /[a-zA-Z_][\w\-]*/

