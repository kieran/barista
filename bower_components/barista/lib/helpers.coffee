# Helper methods
# =============================================


# deep object mixer
mixin = ( ret, mixins... )->
  for obj in mixins
    for own key, val of obj
      if kindof(val) == 'object'
        ret[key] = mixin {}, val
      else
        ret[key] = val
  ret

# better than typeof
kindof = ( o )->
  switch
    when typeof o != "object"     then typeof o
    when o == null                then "null"
    when o.constructor == Array   then "array"
    when o.constructor == Date    then "date"
    when o.constructor == RegExp  then "regex"
    else "object"


module.exports =
  kindof: kindof
  mixin: mixin

