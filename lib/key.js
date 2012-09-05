// new Key( name, optional )
// =================================
// those variable thingies
//
//     key = new Key('name')
//     key = new Key('name', true)
//
var Key = exports.Key = function( name, optional, glob ) {

  this.name = name
  this.optional = (optional===true) ? true : false
  this.glob = (glob===true) ? true : false
  this.regex = this.glob ? /[\w\-\/]+?/ : /[\w\-]+/ // default url-friendly regex

  // special defaults for controllers & actions, which will always be function-name-safe
  if (this.name == 'controller' || this.name == 'action') {
    this.regex = /[a-zA-Z_][\w\-]*/
  }

  return this // just in case we forgot the new operator
};


// key.regexString()
// -----------------
// makes a regex string of the key - used by key.test()
//
// returns a string of this keys regex
//
Key.prototype.regexString = function() {
  var ret = String(this.regex).replace(/^\//, '').replace(/\/[gis]?$/, '')
  if (this.optional) {
    return '(' + ret + ')?'
  }
  return '(' + ret + ')'
};


// key.test( string )
// -----------------
// validates a string using the key's regex pattern
//
// returns true/false if the string matches
//
Key.prototype.test = function( string ) {
  return new RegExp('^'+this.regexString()+'$').test(string)
};


// key.url( string )
// -----------------
// returns a string for buulding the url
// if it matches the key conditions
//
Key.prototype.url = function( string ) {
    return this.test(string) ? string : false
};


// key.where( conditions )
// -----------------------
// adds conditions that the key must match
//
// returns the key... because it can?
//
Key.prototype.where = function( conditions ) {

  var condition = conditions[this.name]

  if (condition instanceof RegExp) this.regex = condition //  e.g. /\d+/

  if (condition instanceof String) this.regex = new RegExp(condition.replace(/^\//, '').replace(/\/[gis]?$/, '')) //  e.g. "\d+"

  //  an array of allowed values, e.g. ['stop','play','pause']
  if (condition instanceof Array) {
    condition = condition.map(function(cond){
      if (cond instanceof RegExp) return cond.toString()
      return cond
    }).map(function(cond){
      return cond.replace(/^\//, '').replace(/\/[gis]?$/, '')
    })
    this.regex = new RegExp(condition.join('|'))
  }

  return this // chainable
}


// key.toString()
// --------------
// returns a unique id that can be compared to other parts
//
Key.prototype.toString = function(){
  return 'key-'+this.name
}