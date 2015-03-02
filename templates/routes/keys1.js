router.match( '/products/:id', 'GET' )
      .to( 'Products.show' )

router.match( '/profiles/:username', 'GET' )
      .to( 'Users.show' )

// things enclosed in parens are optional
router.match( '/products/:id(.:format)', 'GET' )
      .to( 'Products.show' )
