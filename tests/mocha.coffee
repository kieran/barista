assert      = require 'assert'
{ Router }  = require '../index'

router    = null

verbs =
  get:      'GET'
  post:     'POST'
  put:      'PUT'
  del:      'DELETE'
  options:  'OPTIONS'

describe 'Barista', ->

  describe 'new Router', ->
    it 'should return a blank Router object', ->
      router = new Router
      assert.ok router instanceof Router
      assert.equal [].length, router.routes.length

  describe 'calling #match', ->

    beforeEach ->
      router = new Router

    describe 'with a static route', ->
      it 'should not throw an exception', ->
        route = router.match '/path/to/thing'
        assert.ok route, @fail

    describe 'with a keyed route', ->
      it 'should not throw an exception', ->
        route = router.match '/:controller/:action/:id'
        assert.ok route, @fail

    describe 'with a static route and an optional segment', ->
      it 'should not throw an exception', ->
        route = router.match '/:controller/:action/:id(.:format)'
        assert.ok route, @fail

    describe 'with a static route and multiple optional segments', ->
      it 'should not throw an exception', ->
        route = router.match '/:controller/:id(/:action)(.:format)'
        assert.ok route, @fail


    badPaths =
      number: 5
      regexp: /bob/
      object: {}
      array:  []
      date:   new Date
      # string: 'sadsa'

    for key, val of badPaths # BAD BAD BAD, callbacks are referring to the last item set in the outer scope
      do (key,val)->
        it "should throw an error when called with a #{key} for the URL", ->
          assert.throws ->
            router.match val
          , /path must be a string/
          , @fail


  describe '#match with HTTP verbs', ->

    beforeEach ->
      router = new Router

    for method, verb of verbs
      do (method, verb)->
        describe verb, ->
          it 'should not throw an exception', ->
            route = router.match '/:controller/:action', verb
            assert.ok route, @fail

    describe 'WTF', ->
      it 'should throw an exception', ->
        assert.throws ->
          route = router.match '/:controller/:action', 'WTF'


  describe 'convenience methods', ->

    beforeEach ->
      router = new Router

    for method, verb of verbs
      do (method, verb)->

        describe "##{method}", ->
          it "should not throw an exception", ->
            route = router[method] '/path/to/thing'
            assert.ok route

          it "should be equivalent to #match with #{verb}", ->
            one = router[method] '/path/to/thing'
            two = router.match '/path/to/thing', verb
            assert.equal JSON.stringify(one), JSON.stringify two

          it 'should NOT be equivalent to a generic match', ->
            one = router[method] '/path/to/thing'
            two = router.match '/path/to/thing'
            assert.notEqual JSON.stringify(one), JSON.stringify two

          it 'should NOT be equivalent to a false match', ->
            one = router[method] '/path/to/thing'
            two = router.match '/path/to/thing', 'HEAD'
            assert.notEqual JSON.stringify(one), JSON.stringify two

  describe '#first', ->

    beforeEach ->
      router = new Router

    describe 'with a static route', ->

      beforeEach ->
        router.match('/path/to/thing','GET').to('someController.someAction')

      it 'params should match', ->
        paramsIn =
          method:     'GET'
          controller: 'someController'
          action:     'someAction'

        paramsOut = router.first '/path/to/thing', 'GET'

        for key, val of paramsIn
          assert.equal paramsIn[key], paramsOut[key]


    # describe 'a keyed route', ->
    #   it 'should not throw an exception', ->
    #     route = router.match '/:controller/:action/:id'
    #     assert.ok route, @fail

    # describe 'a static route with an optional segment', ->
    #   it 'should not throw an exception', ->
    #     route = router.match '/:controller/:action/:id(.:format)'
    #     assert.ok route, @fail

    # describe 'a static route with multiple optional segments', ->
    #   it 'should not throw an exception', ->
    #     route = router.match '/:controller/:id(/:action)(.:format)'
    #     assert.ok route, @fail
