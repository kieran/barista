// new Key( name, optional )
// =================================
// those variable thingies
// 
//     key = new Key('name')
//     key = new Key('name', true)
//
var Key = function( name, optional ) {

  var self = this

  self.name = name
  self.optional = (optional===true) ? true : false
  self.regex = /[\w\-]+/ // default url-friendly regex

  // special defaults for controllers & actions, which will always be function-name-safe
  if (self.name == 'controller' || self.name == 'action') {
    self.regex = /[a-zA-Z_][\w\-]*/
  }

  // key.regexString()
  // -----------------
  // makes a regex string of the key - used by key.test()
  //
  // returns a string of this keys regex
  this.regexString = function() {
    var ret = String(self.regex).replace(/^\//, '').replace(/\/[gis]?$/, '')
    if (self.optional) {
      return '(' + ret + ')?'
    }
    return '(' + ret + ')'
  };

  // key.test( string )
  // -----------------
  // validates a string using the key's regex pattern
  //
  // returns true/false if the string matches
  this.test = function( string ) {
    return new RegExp('^'+self.regexString()+'$').test(string)
  };

  // key.url( string )
  // -----------------
  // returns a string for buulding the url
  // if it matches the key conditions
  this.url = function( string ) {
    if (self.test(string)) {
      /*
      -- no longer needed 
      snake_caseify the controller, if there is one
      if (self.name == 'controller') return snakeize(string)
      */
      return string
    }
    return false // doesn't match, let it go
  };
  
  // key.where( conditions )
  // -----------------
  // adds conditions that the key must match
  //
  // returns the key... because it can?
  this.where = function( conditions ) {

    var condition = conditions[self.name]

    if (condition instanceof RegExp) self.regex = condition //  e.g. /\d+/

    if (condition instanceof String) self.regex = new RegExp(condition) //  e.g. "/\d+/"
    //  an array of allowed values, e.g. ['stop','play','pause']
    if (condition instanceof Array) self.regex = new RegExp('/'+condition.join('|')+'/')

    return self
  }

  return self // just in case we forgot the new operator
};

exports.Key = Key