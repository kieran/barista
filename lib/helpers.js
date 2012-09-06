// CamelCase
// var camelize = function(str,capitalize){
//   var ret = str.replace( /[^a-zA-Z][a-zA-Z]/g, function(str){
//     return str[1].toUpperCase();
//   });
//   if (capitalize) return ret.replace(/^./,function(str){
//     return str.toUpperCase();
//   });
//   return ret;
// }

// deep object mixer
exports.mixin = function(){
  var args = Array.prototype.slice.call(arguments)

  for ( var i=1; i < args.length; i++ ) {

    for ( var prop in args[i] ) {
      if ( exports.kindof(args[i][prop]) == 'object' ) {
        // deep copy
        args[0][prop] = mixin( {}, args[i][prop] )
      } else {
        // shallow copy
        args[0][prop] = args[i][prop]
      }
    }
  }
  return args[0]
}

// escapes a string on its way in to a regex pattern
exports.regExpEscape = (function() {
  var specials = [ '/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\' ]
  sRE = new RegExp('(\\' + specials.join('|\\') + ')', 'g')
  return function (text) { return text.replace(sRE, '\\$1') }
})();

exports.kindof = function(o) {
  if (typeof(o) != "object") return typeof(o)
  if (o === null) return "null"
  if (o.constructor == (new Array).constructor) return "array"
  if (o.constructor == (new Date).constructor) return "date"
  if (o.constructor == (new RegExp).constructor) return "regex"
  return "object"
}
