assert      = require 'assert'
{ Router }  = require '../index'

bench = (fn) ->
  return true
  start = (new Date).getTime()
  fn() for i in [1..1000]
  console.log "\navg time: #{ ((new Date).getTime() - start) / 1000 }ms for the following test:"

router = null

RouterTests =

  setup: (opts) ->
    router = new Router

  teardown: (test) ->
    console.log "[0;1;32mPASSED  ::  [0m#{test}"

  'test Create Router': ->
    assert.ok router, @fail

  'test Create Static Route': ->
    route = router.match('/path/to/thing')
    assert.ok route, @fail
    bench ->
      router.match '/path/to/thing'


  'test Create Simple Route': ->
    route = router.match('/:controller/:action/:id')
    assert.ok route, @fail
    bench ->
      router.match '/:controller/:action/:id'


  'test Create Optional Route': ->
    route = router.match('/:controller/:action/:id(.:format)')
    assert.ok route, @fail
    bench ->
      router.match '/:controller/:action/:id(.:format)'


  'test Create Multiple Optional Route': ->
    route = router.match('/:controller/:id(/:action)(.:format)')
    assert.ok route, @fail
    bench ->
      router.match '/:controller/:id(/:action)(.:format)'


  'test Create Resource': ->
    resource = router.resource('snow_dogs')
    assert.ok resource.routes.length == 7, @fail
    for i of resource.routes
      assert.ok resource.routes[i], @fail
    bench ->
      router.resource 'snow_dogs'


  'test Route With Params': ->
    route = router.match('/hello/there').to('applicaton.index')
    assert.ok route, @fail
    bench ->
      router.match('/hello/there').to 'applicaton.index'


  'test Route With Extra Params': ->
    route = router.match('/hello/there').to('applicaton.index', language: 'english')
    assert.ok route, @fail

  'test Route With Extra Params And Route-Implied Endpoint': ->
    route = router.match('/:controller/:action').to(language: 'english')
    assert.ok route, @fail

  'test Route With Method': ->
    route = router.match('/:controller/:action', 'GET')
    assert.ok route, @fail

  'test Route With Regex Reqs': ->
    route = router.match('/:controller/:action/:id').where(id: /\d+/)
    assert.ok route, @fail

  'test Route With String Regex Reqs': ->
    route = router.match('/:controller/:action/:id').where(id: '\\d+')
    assert.ok route, @fail

  'test Route With An Array of String Reqs': ->
    route = router.match('/:controller/:action/:id').where(id: [
      'bob'
      'frank'
      'ted'
    ])
    assert.ok route, @fail

  'test Route With An Array of Mixed Reqs': ->
    route = router.match('/:controller/:action/:id').where(id: [
      /\d{1}/
      '\\d\\d'
      '123'
    ])
    assert.ok route, @fail

  'test Route With Reqs And Method': ->
    route = router.match('/:controller/:action/:id', 'GET').where(id: /\d+/)
    assert.ok route, @fail

  'test Route With Name': ->
    route = router.match('/:controller/:action/:id', 'GET').where(id: /\d+/).as('awesome')
    assert.ok route, @fail

  'test Simple Route Parses': ->
    route = router.match('/:controller/:action/:id')
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Simple Route Parses with regex condition': ->
    route = router.match('/:controller/:action/:id').where(id: /\d+/)
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Simple Route Parses with string regex condition': ->
    route = router.match('/:controller/:action/:id').where(id: '\\d+')
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Simple Route Parses with string condition': ->
    route = router.match('/:controller/:action/:id').where(id: '1')
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Simple Route Parses with an array of mixed conditions': ->
    route = router.match('/:controller/:action/:id').where(id: [
      '\\d\\d'
      /\d{1}/
      '123'
    ])
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'

  'test Simple Route resolves with an array of mixed conditions': ->
    route = router.match('/:controller/:action/:id').where(id: [
      'one'
      'two'
      /\d{1}/
    ])
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail

    params = router.first('/products/show/one', 'GET')
    assert.ok params, @fail
    assert.equal params.id, 'one', @fail

    bench ->
      router.first '/products/show/1', 'GET'


  'test Simple Route fails to Parse with bad conditions': ->
    route = router.match('/:controller/:action/:id').where(id: /\d+/)
    params = router.first('/products/show/bob', 'GET')
    assert.equal params, false, @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Callback Fires With Params': ->
    route = router.match('/:controller/:action/:id')
    router.first '/products/show/1', 'GET', (err, params) ->
      assert.ok params, @fail
      assert.equal params.controller, 'products', @fail
      assert.equal params.action, 'show', @fail
      assert.equal params.id, 1, @fail
      assert.equal params.method, 'GET', @fail


  'test Route With Extra Params And Route-Implied Endpoint Parses': ->
    route = router.match('/:controller/:action').to(language: 'english')
    params = router.first('/products/show', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.method, 'GET', @fail
    assert.equal params.language, 'english', @fail

  'test Simple Route Parses With Optional Segment': ->
    route = router.match('/:controller/:action/:id(.:format)')
    params = router.first('/products/show/1.html', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    assert.equal params.format, 'html', @fail
    bench ->
      router.first '/products/show/1.html', 'GET'


  'test Simple Route Parses With Optional Segment Missing': ->
    route = router.match('/:controller/:action/:id(.:format)', 'GET')
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    assert.equal typeof params.format, 'undefined', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Simple Route Failing Due To Bad Method': ->
    route = router.match('/:controller/:action/:id(.:format)', 'GET')
    params = router.first('/products/show/1', 'POST')
    assert.equal params, false, @fail
    bench ->
      router.first '/products/show/1', 'POST'


  'test Simple Route With Two Optional Segments': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'GET')
    params = router.first('/products/show', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal typeof params.id, 'undefined', @fail
    assert.equal typeof params.format, 'undefined', @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show', 'GET'


  'test Simple Route With Two Optional Segments With First Used': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'GET')
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal typeof params.format, 'undefined', @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Simple Route With Two Optional Segments With Second Used': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'GET')
    params = router.first('/products/show.html', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal typeof params.id, 'undefined', @fail
    assert.equal params.format, 'html', @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show.html', 'GET'


  'test Simple Route With Two Optional Segments With Both Used': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'GET')
    params = router.first('/products/show/1.html', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.format, 'html', @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1.html', 'GET'


  'test GET': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'GET')
    params = router.first('/products/show/1.html', 'GET')
    assert.ok params, @fail
    assert.equal params.method, 'GET', @fail

  'test POST': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'POST')
    params = router.first('/products/show/1.html', 'POST')
    assert.ok params, @fail
    assert.equal params.method, 'POST', @fail

  'test PUT': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'PUT')
    params = router.first('/products/show/1.html', 'PUT')
    assert.ok params, @fail
    assert.equal params.method, 'PUT', @fail

  'test PATCH': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'PATCH')
    params = router.first('/products/show/1.html', 'PATCH')
    assert.ok params, @fail
    assert.equal params.method, 'PATCH', @fail

  'test DELETE': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'DELETE')
    params = router.first('/products/show/1.html', 'DELETE')
    assert.ok params, @fail
    assert.equal params.method, 'DELETE', @fail

  'test OPTIONS': ->
    route = router.match('/:controller/:action(/:id)(.:format)', 'OPTIONS')
    params = router.first('/products/show/1.html', 'OPTIONS')
    assert.ok params, @fail
    assert.equal params.method, 'OPTIONS', @fail

  'test GET Shorthand': ->
    route = router.get('/:controller/:action(/:id)(.:format)')
    params = router.first('/products/show/1.html', 'GET')
    assert.ok params, @fail
    assert.equal params.method, 'GET', @fail

  'test POST Shorthand': ->
    route = router.post('/:controller/:action(/:id)(.:format)')
    params = router.first('/products/show/1.html', 'POST')
    assert.ok params, @fail
    assert.equal params.method, 'POST', @fail

  'test PUT Shorthand': ->
    route = router.put('/:controller/:action(/:id)(.:format)')
    params = router.first('/products/show/1.html', 'PUT')
    assert.ok params, @fail
    assert.equal params.method, 'PUT', @fail

  'test PATCH Shorthand': ->
    route = router.patch('/:controller/:action(/:id)(.:format)')
    params = router.first('/products/show/1.html', 'PATCH')
    assert.ok params, @fail
    assert.equal params.method, 'PATCH', @fail

  'test DELETE Shorthand': ->
    route = router.del('/:controller/:action(/:id)(.:format)')
    params = router.first('/products/show/1.html', 'DELETE')
    assert.ok params, @fail
    assert.equal params.method, 'DELETE', @fail
    assert.equal params.action, 'show', @fail

  'test OPTIONS Shorthand': ->
    route = router.options('/:controller/:action(/:id)(.:format)')
    params = router.first('/products/show/1.html', 'OPTIONS')
    assert.ok params, @fail
    assert.equal params.method, 'OPTIONS', @fail
    assert.equal params.action, 'show', @fail

  'test Resource Matches': ->
    routes = router.resource('snow_dogs')
    # index
    assert.ok router.first('/snow_dogs', 'GET'), @fail
    assert.ok router.first('/snow_dogs.html', 'GET'), @fail
    assert.equal router.first('/snow_dogs', 'GET').action, 'index', @fail
    # show
    assert.ok router.first('/snow_dogs/1', 'GET'), @fail
    assert.ok router.first('/snow_dogs/1.html', 'GET'), @fail
    assert.equal router.first('/snow_dogs/1', 'GET').action, 'show', @fail
    # add form
    assert.ok router.first('/snow_dogs/add', 'GET'), @fail
    assert.ok router.first('/snow_dogs/add.html', 'GET'), @fail
    assert.equal router.first('/snow_dogs/add', 'GET').action, 'add', @fail
    # edit form
    assert.ok router.first('/snow_dogs/1/edit', 'GET'), @fail
    assert.ok router.first('/snow_dogs/1/edit.html', 'GET'), @fail
    assert.equal router.first('/snow_dogs/1/edit', 'GET').action, 'edit', @fail
    # create
    assert.ok router.first('/snow_dogs', 'POST'), @fail
    assert.ok router.first('/snow_dogs.html', 'POST'), @fail
    assert.equal router.first('/snow_dogs', 'POST').action, 'create', @fail
    # update
    assert.ok router.first('/snow_dogs/1', 'PUT'), @fail
    assert.ok router.first('/snow_dogs/1.html', 'PUT'), @fail
    assert.equal router.first('/snow_dogs/1', 'PUT').action, 'update', @fail
    # delete
    assert.ok router.first('/snow_dogs/1', 'DELETE'), @fail
    assert.ok router.first('/snow_dogs/1.html', 'DELETE'), @fail
    assert.equal router.first('/snow_dogs/1', 'DELETE').action, 'destroy', @fail

  'test Resource Url Generation': ->
    routes = router.resource('snow_dogs').routes
    # index
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'index'), '/snow_dogs', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'index'
      format: 'html'), '/snow_dogs.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'index'
      format: 'json'), '/snow_dogs.json', @fail
    # show
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'show'
      id: 1), '/snow_dogs/1', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'show'
      id: 1
      format: 'html'), '/snow_dogs/1.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'show'
      id: 1
      format: 'json'), '/snow_dogs/1.json', @fail
    # add form
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'add'), '/snow_dogs/add', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'add'
      format: 'html'), '/snow_dogs/add.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'add'
      format: 'json'), '/snow_dogs/add.json', @fail
    # edit form
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'edit'
      id: 1), '/snow_dogs/1/edit', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'edit'
      id: 1
      format: 'html'), '/snow_dogs/1/edit.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'edit'
      id: 1
      format: 'json'), '/snow_dogs/1/edit.json', @fail
    # create
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'create'), '/snow_dogs', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'create'
      format: 'html'), '/snow_dogs.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'create'
      format: 'json'), '/snow_dogs.json', @fail
    # update
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'update'
      id: 1), '/snow_dogs/1', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'update'
      id: 1
      format: 'html'), '/snow_dogs/1.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'update'
      id: 1
      format: 'json'), '/snow_dogs/1.json', @fail
    # delete
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'destroy'
      id: 1), '/snow_dogs/1', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'destroy'
      id: 1
      format: 'html'), '/snow_dogs/1.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'destroy'
      id: 1
      format: 'json'), '/snow_dogs/1.json', @fail
    bench ->
      router.url
        controller: 'snow_dogs'
        action: 'destroy'
        id: 1
        format: 'json'


  'test Route Url Generation': ->
    route = router.match('/:controller/:action(/:id)(.:format)')
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'pet'), '/snow_dogs/pet', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'pet'
      id: 5), '/snow_dogs/pet/5', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'pet'
      id: 5
      format: 'html'), '/snow_dogs/pet/5.html', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'pet'
      id: 5
      format: 'json'), '/snow_dogs/pet/5.json', @fail
    assert.equal router.url(
      controller: 'snow_dogs'
      action: 'pet'
      format: 'html'), '/snow_dogs/pet.html', @fail
    bench ->
      router.url
        controller: 'snow_dogs'
        action: 'pet'
        id: 5
        format: 'html'


  'test Route Url Generates Route With QueryString Params': ->
    route = router.match('/:controller/:action(/:id)(.:format)')
    # test with QS params ON
    assert.equal router.url({
      controller: 'snow_dogs'
      action: 'pet'
      awesome: 'yes'
    }, true), '/snow_dogs/pet?awesome=yes', @fail

  'test Route Url Generates Route Without QueryString Params': ->
    route = router.match('/:controller/:action(/:id)(.:format)')
    # test with QS params OFF (default behaviour)
    assert.equal router.url({
      controller: 'snow_dogs'
      action: 'pet'
      awesome: 'yes'
    }, false), '/snow_dogs/pet', @fail

  'test Creating a route without a string path will throw an error': ->
    assert.throws ->
      route = router.match(5)
    , /path must be a string/, @fail
    assert.throws ->
      route = router.match(/bob/)
    , /path must be a string/, @fail
    assert.throws ->
      route = router.match({})
    , /path must be a string/, @fail

  'test A route with a glob': ->
    route = router.match('/timezones/*tzname').to(
      controller: 'Timezones'
      action: 'select')
    params = router.first('/timezones/America/New_York', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Timezones'
      action: 'select'
      tzname: 'America/New_York'
    # tests both parsing & generation
    assert.equal router.url(params), '/timezones/America/New_York', @fail
    assert.equal router.url(expectedParams), '/timezones/America/New_York', @fail

  'test A route with a glob and a format': ->
    route = router.match('/timezones/*tzname(.:format)').to(
      controller: 'Timezones'
      action: 'select')
    params = router.first('/timezones/America/New_York.json', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Timezones'
      action: 'select'
      tzname: 'America/New_York'
      format: 'json'
    # tests both parsing & generation
    assert.equal router.url(params), '/timezones/America/New_York.json', @fail
    assert.equal router.url(expectedParams), '/timezones/America/New_York.json', @fail

  'test A route with 2 globs': ->
    route = router.match('/*tzname_one/to/*tzname_two').to(
      controller: 'Timezones'
      action: 'between')
    params = router.first('/America/Toronto/to/America/San_Francisco', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Timezones'
      action: 'between'
      tzname_one: 'America/Toronto'
      tzname_two: 'America/San_Francisco'
    # tests both parsing & generation
    assert.equal router.url(params), '/America/Toronto/to/America/San_Francisco', @fail
    assert.equal router.url(expectedParams), '/America/Toronto/to/America/San_Francisco', @fail

  'test A route with 2 globs and a format': ->
    route = router.match('/*tzname_one/to/*tzname_two(.:format)').to(
      controller: 'Timezones'
      action: 'between')
    params = router.first('/America/Toronto/to/America/San_Francisco.json', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Timezones'
      action: 'between'
      tzname_one: 'America/Toronto'
      tzname_two: 'America/San_Francisco'
      format: 'json'
    # tests both parsing & generation
    assert.equal router.url(params), '/America/Toronto/to/America/San_Francisco.json', @fail
    assert.equal router.url(expectedParams), '/America/Toronto/to/America/San_Francisco.json', @fail

  'test A catch-all path': ->
    route = router.match('/*path(.:format)').to(
      controller: 'Errors'
      action: 'notFound')
    params = router.first('/One/Two/three/four/Five.json', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Errors'
      action: 'notFound'
      path: 'One/Two/three/four/Five'
      format: 'json'
    # tests both parsing & generation
    assert.equal router.url(params), '/One/Two/three/four/Five.json', @fail
    assert.equal router.url(expectedParams), '/One/Two/three/four/Five.json', @fail

  'test finding all matching routes': ->
    routes = router.resource('snow_dogs').routes
    # assert.equal( 2, 2);
    # console.log( JSON.stringify(router.routes,null,2) )
    # console.log( JSON.stringify( router.all('/snow_dogs'), null, 2 ) )
    # assert.equal( router.all('/snow_dogs').length, 2);

  'test A resource with member routes': ->
    route = router.resource('posts').member(->
      @get('/print').to 'Posts.print'

    )
    params = router.first('/posts/5/print', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Posts'
      action: 'print'
      post_id: 5
    # tests both parsing & generation
    assert.equal router.url(params), '/posts/5/print', @fail
    assert.equal router.url(expectedParams), '/posts/5/print', @fail

  'test A resource with collection routes': ->
    route = router.resource('posts').collection(->
      @get('/print').to 'Posts.printAll'

    )
    params = router.first('/posts/print', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Posts'
      action: 'printAll'
    # tests both parsing & generation
    assert.equal router.url(params), '/posts/print', @fail
    assert.equal router.url(expectedParams), '/posts/print', @fail

  'test A resource with member routes with optional segments': ->
    route = router.resource('Posts').member(->
      @get('/print(.:format)').to 'Posts.printAll'

    )
    params = router.first('/posts/5/print.pdf', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Posts'
      action: 'printAll'
      format: 'pdf'
      post_id: 5
    # tests both parsing & generation
    assert.equal router.url(params), '/posts/5/print.pdf', @fail
    assert.equal router.url(expectedParams), '/posts/5/print.pdf', @fail

  'test A resource with member resource': ->
    route = router.resource('Posts').member(->
      @resource 'Comments'

    )
    params = router.first('/posts/5/comments/3', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Comments'
      action: 'show'
      post_id: 5
      id: 3
    # tests both parsing & generation
    assert.equal router.url(params), '/posts/5/comments/3', @fail
    assert.equal router.url(expectedParams), '/posts/5/comments/3', @fail

  'test A resource with collection resource': ->
    route = router.resource('Posts').collection(->
      @resource 'Comments'

    )
    params = router.first('/posts/comments', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Comments'
      action: 'index'
    # tests both parsing & generation
    assert.equal router.url(params), '/posts/comments', @fail
    assert.equal router.url(expectedParams), '/posts/comments', @fail

  'test A HEAD request should resolve to GET': ->
    route = router.get('/something').to('App.index')
    params = router.first('/something', 'HEAD')
    expectedParams =
      method: 'HEAD'
      controller: 'App'
      action: 'index'
    # tests both parsing & generation
    assert.equal router.url(params), '/something', @fail
    assert.equal router.url(expectedParams), '/something', @fail

  'test A HEAD request should not resolve to not-GET': ->
    route = router.post('/something').to('App.index')
    params = router.first('/something', 'HEAD')
    assert.equal params, false, @fail

  'test Nesting: Route -> Route': ->
    route = router.post('/something').to('App.index').nest(->
      @get('/something_else').to 'App.somewhere'

    )
    params = router.first('/something/something_else', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'App'
      action: 'somewhere'
    assert.equal router.url(params), '/something/something_else', @fail
    assert.equal router.url(expectedParams), '/something/something_else', @fail

  'test Nesting: Resource -> Route': ->
    route = router.resource('Posts').nest(->
      @get('/print(.:format)').to 'Posts.print'

    )
    url = '/posts/5/print.pdf'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Posts'
      action: 'print'
      format: 'pdf'
      post_id: 5
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test Nesting: Resource -> Resource': ->
    res = router.resource('Posts').nest(->
      @resource 'Comments'

    )
    url = '/posts/5/comments'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Comments'
      action: 'index'
      post_id: '5'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test Simple Remove': ->
    #Start by repeating the simple route test, to make sure nothing was broken by using name
    route = router.match('/:controller/:action/:id').as('delete_me')
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    #Remove the route
    router.remove 'delete_me'
    params = router.first('/products/show/1', 'GET')
    assert.equal params, false, @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Remove With Multiple Routes': ->
    `var route`
    #Start by repeating the simple route test, to make sure nothing was broken by using name
    route = router.match('/:controller/:action/:id').as('delete_me')
    route = router.match('/a/:controller/:action/:id').as('do_not_delete_me')
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    params = router.first('/a/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    #Remove the route
    router.remove 'delete_me'
    params = router.first('/products/show/1', 'GET')
    assert.equal params, false, @fail
    params = router.first('/a/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test Bad Remove does no damage and fails to remove good route': ->
    #Same as the simple route test, with the invalid delete in the middle
    route = router.match('/:controller/:action/:id').as('do_not_delete_me')
    router.remove 'delete_me'
    params = router.first('/products/show/1', 'GET')
    assert.ok params, @fail
    assert.equal params.controller, 'products', @fail
    assert.equal params.action, 'show', @fail
    assert.equal params.id, 1, @fail
    assert.equal params.method, 'GET', @fail
    bench ->
      router.first '/products/show/1', 'GET'


  'test A route with URI encoded params': ->
    route = router.match('/something_with/:weird_shit').to(
      controller: 'Wat'
      action: 'lol')
    params = router.first('/something_with/cray cray param', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Wat'
      action: 'lol'
      weird_shit: 'cray cray param'
    # tests both parsing & generation
    assert.equal router.url(params), '/something_with/cray cray param', @fail
    assert.equal router.url(expectedParams), '/something_with/cray cray param', @fail

  'test A route with base64 encoded params': ->
    b64_regex = /[\w\-\/+]+={0,2}/
    route = router.match('/something_with/:weird_shit').to(
      controller: 'Wat'
      action: 'lol').where(weird_shit: b64_regex)
    test_url = '/something_with/R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs='
    params = router.first(test_url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Wat'
      action: 'lol'
      weird_shit: 'R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs='
    # tests both parsing & generation
    assert.equal router.url(params), test_url, @fail
    assert.equal router.url(expectedParams), test_url, @fail

  'test all with a simple route': ->
    # with thanks to @larzconwell
    route1 = router.match('/all_routes/test').to(
      controller: 'All'
      action: 'test')
    route2 = router.match('/*whatever_path').to(
      controller: 'All'
      action: 'test2')
    routes = router.all('/all_routes/test', 'GET')
    expectedRoutes = [
      {
        method: 'GET'
        controller: 'All'
        action: 'test'
      }
      {
        method: 'GET'
        controller: 'All'
        action: 'test2'
        whatever_path: 'all_routes/test'
      }
    ]
    assert.deepEqual routes, expectedRoutes

  'test Route With Regex Reqs and periods in the var': ->
    route = router.get('/sites/:id/edit').to('sites.edit').where(id: /[\w\-\s.]+/)
    params = router.first('/sites/site.ru/edit', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'sites'
      action: 'edit'
      id: 'site.ru'
    assert.equal router.url(params), '/sites/site.ru/edit', @fail
    assert.equal router.url(expectedParams), '/sites/site.ru/edit', @fail

  'test nested admin route works': ->
    admin_ns = router.match('/admin').to('errors.index').nest(->
      @resource 'Posts'

    )
    params = router.first('/admin/posts/456', 'GET')
    expectedParams =
      method: 'GET'
      controller: 'Posts'
      action: 'show'
      id: 456
    assert.equal router.url(params), '/admin/posts/456', @fail
    assert.equal router.url(expectedParams), '/admin/posts/456', @fail

  'test nested optional parts 1': ->
    route = router.match('/:controller(/:action(/:id))(.:format)', 'GET')
    url = '/products/show/1.pdf'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'products'
      action: 'show'
      id: 1
      format: 'pdf'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test nested optional parts 2': ->
    route = router.match('/:controller(/:action(/:id))(.:format)', 'GET')
    url = '/products/show'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'products'
      action: 'show'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test nested optional parts 3': ->
    route = router.match('/:controller(/:action(/:id))(.:format)', 'GET')
    url = '/products'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'products'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test nested optional parts 4': ->
    route = router.match('/:controller(/:action(/:id))(.:format)', 'GET')
    url = '/products/show.pdf'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'products'
      action: 'show'
      format: 'pdf'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test nested optional parts 5': ->
    route = router.match('/:controller(/:action(/:id))(.:format)', 'GET')
    url = '/products.pdf'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'products'
      format: 'pdf'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test find by email': ->
    route = router.match('/users/find_by_email/:email', 'GET').where(email: /[\w.@]+?/).to('users.find_by_email')
    url = '/users/find_by_email/kieran@kieran.ca'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'users'
      action: 'find_by_email'
      email: 'kieran@kieran.ca'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test find by email with sub-route': ->
    route = router.match('/users/find_by_email/:email/favourites', 'GET').where(email: /[\w.@]+?/).to('users.favourites')
    url = '/users/find_by_email/kieran@kieran.ca/favourites'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'users'
      action: 'favourites'
      email: 'kieran@kieran.ca'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

  'test find by email with nested sub-route preserves where conditions': ->
    route = router.match('/users/find_by_email/:email', 'GET').where(email: /[\w.@]+?/).to('users.find_by_email').nest(->
      @get('/favourites').to 'users.favourites'

    )
    url = '/users/find_by_email/kieran@kieran.ca/favourites'
    params = router.first(url, 'GET')
    expectedParams =
      method: 'GET'
      controller: 'users'
      action: 'favourites'
      email: 'kieran@kieran.ca'
    assert.equal router.url(params), url, @fail
    assert.equal router.url(expectedParams), url, @fail

# Run tests -- additionally setting up custom failure message and calling setup() and teardown()
for e, test of RouterTests
  if e.match /test/
    RouterTests.fail = "[0;1;31mFAILED  ::  [0m#{e}"
    try
      RouterTests.setup()
      test()
      RouterTests.teardown e
    catch e
      console.log RouterTests.fail
      console.log e
