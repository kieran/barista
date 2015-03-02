// is equivalent to
router.get( '/posts(.:format)' )
      .to( 'Posts.index' )

router.get( '/posts/add(.:format)' )
      .to( 'Posts.add' )

router.get( '/posts/:id(.:format)' )
      .to( 'Posts.show' )

router.get( '/posts/:id/edit(.:format)' )
      .to( 'Posts.edit' )

router.post( '/posts(.:format)' )
      .to( 'Posts.create' )

router.put( '/posts/:id(.:format)' )
      .to( 'Posts.update' )

router.del( '/posts/:id(.:format)' )
      .to( 'Posts.destroy' )
