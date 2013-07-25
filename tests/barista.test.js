var util      = require ('util')
  , assert    = require('assert')
  , Router    = require('../index').Router;


RouterTests = {
  //pass and fail messages to be used in reporting success or failure

  //basic test setup
  setup : function(opts) {
    return function() {
      router = new Router();
    }();
  },

  //tear down must be run at the completion of every test
  teardown : function(test) {
    util.puts("\033[0;1;32mPASSED  ::  \033[0m" + test);
    return function() {
      process.addListener("exit", function () {
        assert.equal(0, exitStatus);
      })();
    }
  },

 // create a router
  'test Create Router' : function() {
    assert.ok(router, this.fail);
  },

  // create a simple route
  'test Create Static Route' : function() {
    var route = router.match('/path/to/thing');
    assert.ok(route, this.fail);
    bench(function(){
      router.match('/path/to/thing');
    });
  },

  // create a simple route
  'test Create Simple Route' : function() {
    var route = router.match('/:controller/:action/:id');
    assert.ok(route, this.fail);
    bench(function(){
      router.match('/:controller/:action/:id');
    });
  },

  // create a route with optional segments
  'test Create Optional Route' : function() {
    var route = router.match('/:controller/:action/:id(.:format)')
    assert.ok(route, this.fail)
    bench(function(){
      router.match('/:controller/:action/:id(.:format)')
    });
  },

  // create a route with multiple optional segments
  'test Create Multiple Optional Route' : function() {
    var route = router.match('/:controller/:id(/:action)(.:format)')
    assert.ok(route, this.fail)
    bench(function(){
      router.match('/:controller/:id(/:action)(.:format)')
    });
  },

  // create a resource
  'test Create Resource' : function() {
    var resource = router.resource('snow_dogs');
    assert.ok(resource.routes.length === 7, this.fail)
    for ( var i in resource.routes ) {
      assert.ok(resource.routes[i], this.fail)
    }
    bench(function(){
      router.resource('snow_dogs');
    });
  },

  // create a static route with fixed params
  'test Route With Params' : function() {
    var route = router.match('/hello/there').to( 'applicaton.index' );
    assert.ok(route, this.fail)
    bench(function(){
      router.match('/hello/there').to( 'applicaton.index' );
    });
  },

  // create a static route with extra fixed params
  'test Route With Extra Params' : function() {
    var route = router.match('/hello/there').to( 'applicaton.index', { language: 'english' } );
    assert.ok(route, this.fail)
  },

  // create a static route with extra fixed params
  'test Route With Extra Params And Route-Implied Endpoint' : function() {
    var route = router.match('/:controller/:action').to( { language: 'english' } );
    assert.ok(route, this.fail)
  },

  // create a static route with a specific request method
  'test Route With Method' : function() {
    var route = router.match('/:controller/:action', 'GET');
    assert.ok(route, this.fail)
  },

  // create a static route with key regex match requirements
  'test Route With Regex Reqs' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: /\d+/ } );
    assert.ok(route, this.fail)
  },

  // create a static route with key match requirements as a regex string
  'test Route With String Regex Reqs' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: '\\d+' } );
    assert.ok(route, this.fail)
  },

  // create a static route with key match requirements as an array of strings
  'test Route With An Array of String Reqs' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: [ 'bob', 'frank', 'ted' ] } );
    assert.ok(route, this.fail)
  },

  // create a static route with key match requirements as a mixed array
  'test Route With An Array of Mixed Reqs' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: [ /\d{1}/, '\\d\\d', '123' ] } );
    assert.ok(route, this.fail)
  },

  // create a static route with key match requirements AND a method
  'test Route With Reqs And Method' : function() {
    var route = router.match('/:controller/:action/:id', 'GET').where( { id: /\d+/ } );
    assert.ok(route, this.fail)
  },

  // create a static route with key match requirements AND a method in reverse order
  'test Route With Name' : function() {
    var route = router.match('/:controller/:action/:id', 'GET').where( { id: /\d+/ } ).name('awesome');
    assert.ok(route, this.fail)
  },


// ok - let's start doing things with these routes

  // test that the router matches a URL
  'test Simple Route Parses' : function() {
    var route = router.match('/:controller/:action/:id');
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  // test that the route accepts a regexp parameter
  'test Simple Route Parses with regex condition' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: /\d+/ } );
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  // test that the route accepts a string regex condition
  'test Simple Route Parses with string regex condition' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: '\\d+' } );
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  // test that the route accepts a string condition
  'test Simple Route Parses with string condition' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: '1' } );
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  // test that the route accepts an array of mixed condition
  'test Simple Route Parses with an array of mixed conditions' : function() {
    var route = router.match('/:controller/:action/:id')
                      .where({ id: [ '\\d\\d', /\d{1}/, '123' ] });
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  // test that the route rejects a bad regexp parameter
  'test Simple Route fails to Parse with bad conditions' : function() {
    var route = router.match('/:controller/:action/:id').where( { id: /\d+/ } );
    var params = router.first('/products/show/bob','GET');
    assert.equal(params, false, this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  // test that the callback fires with the right args
  'test Callback Fires With Params' : function() {
    var route = router.match('/:controller/:action/:id');
    router.first('/products/show/1','GET',function(err,params){
      assert.ok(params, this.fail);
      assert.equal(params.controller, 'products', this.fail);
      assert.equal(params.action, 'show', this.fail);
      assert.equal(params.id, 1, this.fail);
      assert.equal(params.method, 'GET', this.fail);
    });
  },

  // create a static route with extra fixed params
  'test Route With Extra Params And Route-Implied Endpoint Parses' : function() {
    var route = router.match('/:controller/:action').to( { language: 'english' } );
    var params = router.first('/products/show','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.method, 'GET', this.fail);
    assert.equal(params.language, 'english', this.fail);
  },

  // test that the router matches a URL
  'test Simple Route Parses With Optional Segment' : function() {
    var route = router.match('/:controller/:action/:id(.:format)');
    var params = router.first('/products/show/1.html','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);
    assert.equal(params.format, 'html', this.fail);

    bench(function(){
      router.first('/products/show/1.html','GET');
    });
  },

  'test Simple Route Parses With Optional Segment Missing' : function() {
    var route = router.match('/:controller/:action/:id(.:format)','GET');
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);
    assert.equal(typeof(params.format), 'undefined', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  'test Simple Route Failing Due To Bad Method' : function() {
    var route = router.match('/:controller/:action/:id(.:format)','GET');
    var params = router.first('/products/show/1','POST');
    assert.equal(params, false, this.fail);

    bench(function(){
      router.first('/products/show/1','POST');
    });
  },

  'test Simple Route With Two Optional Segments' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','GET');
    var params = router.first('/products/show','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(typeof(params.id), 'undefined', this.fail);
    assert.equal(typeof(params.format), 'undefined', this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show','GET');
    });
  },

  'test Simple Route With Two Optional Segments With First Used' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','GET');
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(typeof(params.format), 'undefined', this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  'test Simple Route With Two Optional Segments With Second Used' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','GET');
    var params = router.first('/products/show.html','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(typeof(params.id), 'undefined', this.fail);
    assert.equal(params.format, 'html', this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show.html','GET');
    });
  },

  'test Simple Route With Two Optional Segments With Both Used' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','GET');
    var params = router.first('/products/show/1.html','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.format, 'html', this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1.html','GET');
    });
  },

// fuck, how repetitive. how about methods for a bit?

  'test GET' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','GET');
    var params = router.first('/products/show/1.html','GET');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'GET', this.fail);
  },

  'test POST' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','POST');
    var params = router.first('/products/show/1.html','POST');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'POST', this.fail);
  },

  'test PUT' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','PUT');
    var params = router.first('/products/show/1.html','PUT');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'PUT', this.fail);
  },

  'test DELETE' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','DELETE');
    var params = router.first('/products/show/1.html','DELETE');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'DELETE', this.fail);
  },

  'test OPTIONS' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)','OPTIONS');
    var params = router.first('/products/show/1.html','OPTIONS');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'OPTIONS', this.fail);
  },

  'test GET Shorthand' : function() {
    var route = router.get('/:controller/:action(/:id)(.:format)');
    var params = router.first('/products/show/1.html','GET');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'GET', this.fail);
  },

  'test POST Shorthand' : function() {
    var route = router.post('/:controller/:action(/:id)(.:format)');
    var params = router.first('/products/show/1.html','POST');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'POST', this.fail);
  },

  'test PUT Shorthand' : function() {
    var route = router.put('/:controller/:action(/:id)(.:format)');
    var params = router.first('/products/show/1.html','PUT');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'PUT', this.fail);
  },

  'test DELETE Shorthand' : function() {
    var route = router.del('/:controller/:action(/:id)(.:format)');
    var params = router.first('/products/show/1.html','DELETE');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'DELETE', this.fail);
    assert.equal(params.action, 'show', this.fail);
  },

  'test OPTIONS Shorthand' : function() {
    var route = router.options('/:controller/:action(/:id)(.:format)');
    var params = router.first('/products/show/1.html','OPTIONS');
    assert.ok(params, this.fail);
    assert.equal(params.method, 'OPTIONS', this.fail);
    assert.equal(params.action, 'show', this.fail);
  },


// that was fun. Let's do a little resource testing

  'test Resource Matches' : function() {
    var routes = router.resource('snow_dogs');

    // index
    assert.ok( router.first('/snow_dogs','GET'), this.fail);
    assert.ok( router.first('/snow_dogs.html','GET'), this.fail);
    assert.equal( router.first('/snow_dogs','GET').action, 'index', this.fail);
    // show
    assert.ok( router.first('/snow_dogs/1','GET'), this.fail);
    assert.ok( router.first('/snow_dogs/1.html','GET'), this.fail);
    assert.equal( router.first('/snow_dogs/1','GET').action, 'show', this.fail);
    // add form
    assert.ok( router.first('/snow_dogs/add','GET'), this.fail);
    assert.ok( router.first('/snow_dogs/add.html','GET'), this.fail);
    assert.equal( router.first('/snow_dogs/add','GET').action, 'add', this.fail);
    // edit form
    assert.ok( router.first('/snow_dogs/1/edit','GET'), this.fail);
    assert.ok( router.first('/snow_dogs/1/edit.html','GET'), this.fail);
    assert.equal( router.first('/snow_dogs/1/edit','GET').action, 'edit', this.fail);
    // create
    assert.ok( router.first('/snow_dogs','POST'), this.fail);
    assert.ok( router.first('/snow_dogs.html','POST'), this.fail);
    assert.equal( router.first('/snow_dogs','POST').action, 'create', this.fail);
    // update
    assert.ok( router.first('/snow_dogs/1','PUT'), this.fail);
    assert.ok( router.first('/snow_dogs/1.html','PUT'), this.fail);
    assert.equal( router.first('/snow_dogs/1','PUT').action, 'update', this.fail);
    // delete
    assert.ok( router.first('/snow_dogs/1','DELETE'), this.fail);
    assert.ok( router.first('/snow_dogs/1.html','DELETE'), this.fail);
    assert.equal( router.first('/snow_dogs/1','DELETE').action, 'destroy', this.fail);
  },

// url generation time nao

  'test Resource Url Generation' : function() {
    var routes = router.resource('snow_dogs').routes;

    // index
    assert.equal( router.url( { controller:'snow_dogs', action:'index' } ), '/snow_dogs', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'index', format: 'html' } ), '/snow_dogs.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'index', format: 'json' } ), '/snow_dogs.json', this.fail);
    // show
    assert.equal( router.url( { controller:'snow_dogs', action:'show', id:1 } ), '/snow_dogs/1', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'show', id:1, format: 'html' } ), '/snow_dogs/1.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'show', id:1, format: 'json' } ), '/snow_dogs/1.json', this.fail);
    // add form
    assert.equal( router.url( { controller:'snow_dogs', action:'add' } ), '/snow_dogs/add', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'add', format: 'html' } ), '/snow_dogs/add.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'add', format: 'json' } ), '/snow_dogs/add.json', this.fail);
    // edit form
    assert.equal( router.url( { controller:'snow_dogs', action:'edit', id:1 } ), '/snow_dogs/1/edit', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'edit', id:1, format: 'html' } ), '/snow_dogs/1/edit.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'edit', id:1, format: 'json' } ), '/snow_dogs/1/edit.json', this.fail);
    // create
    assert.equal( router.url( { controller:'snow_dogs', action:'create' } ), '/snow_dogs', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'create', format: 'html' } ), '/snow_dogs.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'create', format: 'json' } ), '/snow_dogs.json', this.fail);
    // update
    assert.equal( router.url( { controller:'snow_dogs', action:'update', id:1 } ), '/snow_dogs/1', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'update', id:1, format: 'html' } ), '/snow_dogs/1.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'update', id:1, format: 'json' } ), '/snow_dogs/1.json', this.fail);
    // delete
    assert.equal( router.url( { controller:'snow_dogs', action:'destroy', id:1 } ), '/snow_dogs/1', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'destroy', id:1, format: 'html' } ), '/snow_dogs/1.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'destroy', id:1, format: 'json' } ), '/snow_dogs/1.json', this.fail);

    bench(function(){
      router.url( { controller:'snow_dogs', action:'destroy', id:1, format: 'json' } )
    });
  },

  'test Route Url Generation' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)');

    assert.equal( router.url( { controller:'snow_dogs', action:'pet' } ), '/snow_dogs/pet', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'pet', id:5 } ), '/snow_dogs/pet/5', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'pet', id:5, format:'html' } ), '/snow_dogs/pet/5.html', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'pet', id:5, format:'json' } ), '/snow_dogs/pet/5.json', this.fail);
    assert.equal( router.url( { controller:'snow_dogs', action:'pet', format:'html' } ), '/snow_dogs/pet.html', this.fail);

    bench(function(){
      router.url( { controller:'snow_dogs', action:'pet', id:5, format:'html' } )
    });
  },

  'test Route Url Generates Route With QueryString Params' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)');
    // test with QS params ON
    assert.equal( router.url( { controller:'snow_dogs', action:'pet', awesome:'yes' }, true ), '/snow_dogs/pet?awesome=yes', this.fail);
  },

  'test Route Url Generates Route Without QueryString Params' : function() {
    var route = router.match('/:controller/:action(/:id)(.:format)');
    // test with QS params OFF (default behaviour)
    assert.equal( router.url( { controller:'snow_dogs', action:'pet', awesome:'yes' }, false ), '/snow_dogs/pet', this.fail);
  },

  'test Creating a route without a string path will throw an error' : function() {
    assert.throws( function() {
      var route = router.match(5)
    }, /path must be a string/,
    this.fail );
    assert.throws( function() {
      var route = router.match(/bob/)
    }, /path must be a string/,
    this.fail );
    assert.throws( function() {
      var route = router.match({})
    }, /path must be a string/,
    this.fail );
  },

  'test A route with a glob' : function() {
    var route = router.match('/timezones/*tzname').to( { controller:'Timezones', action:'select' } )
      , params = router.first('/timezones/America/New_York','GET')
      , expectedParams = { method:'GET', controller:'Timezones', action:'select', tzname:'America/New_York' }

    // tests both parsing & generation
    assert.equal( router.url( params ), '/timezones/America/New_York', this.fail);
    assert.equal( router.url( expectedParams ), '/timezones/America/New_York', this.fail);
  },

  'test A route with a glob and a format' : function() {
    var route = router.match('/timezones/*tzname(.:format)').to( { controller:'Timezones', action:'select' } )
      , params = router.first('/timezones/America/New_York.json','GET')
      , expectedParams = { method:'GET', controller:'Timezones', action:'select', tzname:'America/New_York', format:'json' }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/timezones/America/New_York.json', this.fail);
	  assert.equal( router.url( expectedParams ), '/timezones/America/New_York.json', this.fail);
  },

  'test A route with 2 globs' : function() {
    var route = router.match('/*tzname_one/to/*tzname_two').to( { controller:'Timezones', action:'between' } )
      , params = router.first('/America/Toronto/to/America/San_Francisco','GET')
      , expectedParams = { method:'GET', controller:'Timezones', action:'between', tzname_one:'America/Toronto', tzname_two:'America/San_Francisco' }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/America/Toronto/to/America/San_Francisco', this.fail);
	  assert.equal( router.url( expectedParams ), '/America/Toronto/to/America/San_Francisco', this.fail);
  },

  'test A route with 2 globs and a format' : function() {
    var route = router.match('/*tzname_one/to/*tzname_two(.:format)').to( { controller:'Timezones', action:'between' } )
      , params = router.first('/America/Toronto/to/America/San_Francisco.json','GET')
      , expectedParams = { method:'GET', controller:'Timezones', action:'between', tzname_one:'America/Toronto', tzname_two:'America/San_Francisco', format:'json' }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/America/Toronto/to/America/San_Francisco.json', this.fail);
	  assert.equal( router.url( expectedParams ), '/America/Toronto/to/America/San_Francisco.json', this.fail);
  },

  'test A catch-all path' : function() {
    var route = router.match('/*path(.:format)').to( { controller:'Errors', action:'notFound' } )
      , params = router.first('/One/Two/three/four/Five.json','GET')
      , expectedParams = { method:'GET', controller:'Errors', action:'notFound', path:'One/Two/three/four/Five', format:'json' }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/One/Two/three/four/Five.json', this.fail);
	  assert.equal( router.url( expectedParams ), '/One/Two/three/four/Five.json', this.fail);
  },

  'test finding all matching routes' : function() {
    var routes = router.resource('snow_dogs').routes;
    // assert.equal( 2, 2);
    // util.puts( JSON.stringify(router.routes,null,2) )
    // util.puts( JSON.stringify( router.all('/snow_dogs'), null, 2 ) )
    // assert.equal( router.all('/snow_dogs').length, 2);
  },

  'test A resource with member routes' : function() {
    var route = router.resource('posts').member(function(){
      this.get('/print').to('Posts.print')
    })

    var params = router.first('/posts/5/print','GET')

    var expectedParams = { method:'GET', controller:'Posts', action:'print', post_id:5 }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/posts/5/print', this.fail);
	  assert.equal( router.url( expectedParams ), '/posts/5/print', this.fail);
  },

  'test A resource with collection routes' : function() {
    var route = router.resource('posts').collection(function(){
      this.get('/print').to('Posts.printAll')
    })

    , params = router.first('/posts/print','GET')
    , expectedParams = { method:'GET', controller:'Posts', action:'printAll' }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/posts/print', this.fail);
	  assert.equal( router.url( expectedParams ), '/posts/print', this.fail);
  },

  'test A resource with member routes with optional segments' : function() {
    var route = router.resource('Posts').member(function(){
      this.get('/print(.:format)').to('Posts.printAll')
    })

    , params = router.first('/posts/5/print.pdf','GET')
    , expectedParams = { method:'GET', controller:'Posts', action:'printAll', format: 'pdf', post_id:5 }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/posts/5/print.pdf', this.fail);
	  assert.equal( router.url( expectedParams ), '/posts/5/print.pdf', this.fail);

  },

  'test A resource with member resource' : function() {
    var route = router.resource('Posts').member(function(){
      this.resource('Comments')
    })

    , params = router.first('/posts/5/comments/3','GET')
    , expectedParams = { method:'GET', controller:'Comments', action:'show', post_id:5, id:3 }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/posts/5/comments/3', this.fail);
	  assert.equal( router.url( expectedParams ), '/posts/5/comments/3', this.fail);

  },

  'test A resource with collection resource' : function() {
    var route = router.resource('Posts').collection(function(){
      this.resource('Comments')
    })

    , params = router.first('/posts/comments','GET')
    , expectedParams = { method:'GET', controller:'Comments', action:'index' }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/posts/comments', this.fail);
	  assert.equal( router.url( expectedParams ), '/posts/comments', this.fail);

  },

  'test A HEAD request should resolve to GET' : function() {
    var route = router.get('/something').to('App.index')

    , params = router.first('/something','HEAD')
    , expectedParams = { method:'HEAD', controller:'App', action:'index' }

    // tests both parsing & generation
	  assert.equal( router.url( params ), '/something', this.fail);
	  assert.equal( router.url( expectedParams ), '/something', this.fail);

  },

  'test A HEAD request should not resolve to not-GET' : function() {
    var route = router.post('/something').to('App.index')
    , params = router.first('/something','HEAD')

    assert.equal( params, false, this.fail );
  },

  'test Nesting: Route -> Route' : function() {
    var route = router.post('/something').to('App.index').nest(function(){
      this.get('/something_else').to('App.somewhere')
    })
    , params = router.first('/something/something_else','GET')
    , expectedParams = { method:'GET', controller:'App', action:'somewhere' }

    debugger


	  assert.equal( router.url( params ), '/something/something_else', this.fail);
	  assert.equal( router.url( expectedParams ), '/something/something_else', this.fail);
  },

  'test Nesting: Resource -> Route' : function() {
    var route = router.resource('Posts').nest(function(){
      this.get('/print(.:format)').to('Posts.print')
    })

    var url = '/posts/5/print.pdf'
      , params = router.first(url,'GET')
      , expectedParams = { method:'GET', controller:'Posts', action:'print', format:'pdf', post_id:5 }

	  assert.equal( router.url( params ), url, this.fail);
	  assert.equal( router.url( expectedParams ), url, this.fail);
  },

  'test Nesting: Resource -> Resource' : function() {
    var res = router.resource('Posts').nest(function(){
      this.resource('Comments')
    })

    var url = '/posts/5/comments'
      , params = router.first(url,'GET')
      , expectedParams = { method:'GET', controller:'Comments', action:'index', post_id:'5' }

	  assert.equal( router.url( params ), url, this.fail);
	  assert.equal( router.url( expectedParams ), url, this.fail);
  },
  'test Simple Remove' : function() {

    //Start by repeating the simple route test, to make sure nothing was broken by using name
    var route = router.match('/:controller/:action/:id').name("delete_me");
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    //Remove the route
    router.remove("delete_me");

    params = router.first('/products/show/1','GET');
    assert.equal(params, false, this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },
  'test Remove With Multiple Routes' : function() {

    //Start by repeating the simple route test, to make sure nothing was broken by using name
    var route = router.match('/:controller/:action/:id').name("delete_me");
    var route = router.match('/a/:controller/:action/:id').name("do_not_delete_me");
    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);
    params = router.first('/a/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    //Remove the route
    router.remove("delete_me");

    params = router.first('/products/show/1','GET');
    assert.equal(params, false, this.fail);
    params = router.first('/a/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },
  'test Bad Remove does no damage and fails to remove good route' : function() {

    //Same as the simple route test, with the invalid delete in the middle
    var route = router.match('/:controller/:action/:id').name("do_not_delete_me");
    router.remove("delete_me");

    var params = router.first('/products/show/1','GET');
    assert.ok(params, this.fail);
    assert.equal(params.controller, 'products', this.fail);
    assert.equal(params.action, 'show', this.fail);
    assert.equal(params.id, 1, this.fail);
    assert.equal(params.method, 'GET', this.fail);

    bench(function(){
      router.first('/products/show/1','GET');
    });
  },

  'test A route with URI encoded params' : function() {

    var route = router.match('/something_with/:weird_shit').to( { controller:'Wat', action:'lol' } )
      , params = router.first('/something_with/cray cray param','GET')
      , expectedParams = { method:'GET', controller:'Wat', action:'lol', weird_shit:'cray cray param' }

    // tests both parsing & generation
    assert.equal( router.url( params ), '/something_with/cray cray param', this.fail);
    assert.equal( router.url( expectedParams ), '/something_with/cray cray param', this.fail);
  },

  'test all with a simple route': function () {
    // with thanks to @larzconwell
    var route1 = router.match('/all_routes/test').to( { controller:'All', action: 'test' } )
      , route2 = router.match('/*whatever_path').to( { controller:'All', action: 'test2' } )
      , routes = router.all('/all_routes/test', 'GET')
      , expectedRoutes = [{ method: 'GET', controller: 'All', action: 'test' },{ method: 'GET', controller:'All', action: 'test2', whatever_path: 'all_routes/test' } ];

    assert.deepEqual(routes, expectedRoutes);
  },


  //
  //
  //   'test Nesting: Resource -> Route -> Resource -> Route' : function() {
  //     var res = router.resource('Ones').collection(function(){
  //       this.get('/twos').to('Twos.index').nest(function(){
  //         this.resource('Threes').collection(function(){
  //           this.get('/fours').to('Fours.index')
  //         })
  //       })
  //     })
  // router.list()
  // console.log(router.first('/ones/twos/threes/fours'))
  //     var url = '/ones/twos/threes/fours'
  //       , params = router.first(url,'GET')
  //       , expectedParams = { method:'GET', controller:'Fours', action:'index' }
  //
  //    assert.equal( router.url( params ), url, this.fail);
  //    assert.equal( router.url( expectedParams ), url, this.fail);
  //   },
}

function bench(fn){
  return true
  var start = new Date().getTime();
  for ( var i=0; i<1000; i++ ) {
    fn();
  }
  util.puts('\navg time: '+(new Date().getTime() - start) / 1000 + 'ms for the following test:');
}


// Run tests -- additionally setting up custom failure message and calling setup() and teardown()
for(e in RouterTests) {
  if (e.match(/test/)) {
    RouterTests.fail = "\033[0;1;31mFAILED  ::  \033[0m" + e;
    try {
      RouterTests.setup();
      RouterTests[e]();
      RouterTests.teardown(e);
    } catch (e) {
      util.puts(RouterTests.fail)
    }
  }
}
