{ kindof, mixin } = require './helpers'

# new Key( name, optional )
# =================================
# those variable thingies
#
#     key = new Key('name')
#     key = new Key('name', true)
#
exports.Key =
class Key
  regex: /[\w\-\s]+/
  constructor: ( @name, @optional )->

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
    ret = ['(']
    ret.push @regex.source
    ret.push ')'
    ret.push '?' if @optional
    ret.join ''


  # key.test( string )
  # -----------------
  # validates a string using the key's regex pattern
  #
  # returns true/false if the string matches
  #
  test: ( string )-> # this regex test passes for null & undefined :-(
    new RegExp("^#{@regexString()}$").test string


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
      @regex = new RegExp condition #  e.g. "\d+"

    #  an array of allowed values, e.g. ['stop','play','pause']
    if condition instanceof Array
      ret = []
      for c in condition
        ret.push c.source if 'regex' == kindof c
        ret.push c if 'string' == kindof c
      @regex = new RegExp ret.join '|'

    this # chainable


  # key.toString()
  # --------------
  # returns the original key definition
  #
  toString: ->
    ":#{@name}"


  @regex = /:([a-zA-Z_][\w\-]*)/
  @parse = ( string, optional=false )->
    [ definition, name ] = @regex.exec string
    new @ name, optional

# new Glob( name, optional )
# =================================
# globs are just greedy keys
#
#     glob = new Glob('name')
#     glob = new Glob('name', true)
#
exports.Glob =
class Glob extends Key
  regex: /[\w\-\/\s]+?/ # default url-friendly regex
  constructor: ( @name, @optional )->
    # special defaults for controllers & actions, which will always be function-name-safe
    if @name == 'controller' || @name == 'action'
      @regex = /[a-zA-Z_][\w\-]*/

  # glob.toString()
  # ---------------
  # returns the original glob definition
  #
  toString: ->
    "*#{@name}"

  @regex = /\*([a-zA-Z_][\w\-]*)/
