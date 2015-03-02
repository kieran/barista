// assuming the following route definition:
router.resource( 'Posts' )

// then the URL resolves like so:
router.first( '/posts/123.json', 'GET' )
