# new Text( name, optional )
# ============================
# those variable thingies
#
#     text = new Static('text')
#
exports.Text =
class Text
  constructor: ( @text )->


  # text.regexString()
  # --------------------
  # makes a regex string of the text path - used by text.test()
  #
  # returns a string of this path's regex
  #
  regexString: ->
    regExpEscape @text


  # text.test( string )
  # ---------------------
  # validates a string using the key's regex pattern
  #
  # returns true/false if the string matches
  #
  test: ( string )->
    @text == string


  # text.url( string )
  # --------------------
  # returns a string for building the url
  # if it matches the key conditions
  #
  url: ( string )->
    if @test(string) then string else false


  # text.toString()
  # -----------------
  # returns a unique id that can be compared to other parts
  #
  toString: ->
    "text-#{@text}"

regExpEscape = do ->
  specials = [ '/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\' ]
  sRE = new RegExp "(\\#{ specials.join '|\\' })", 'g'
  ( text )-> text.replace sRE, '\\$1'
