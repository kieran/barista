// assuming the following route definition:
router.resource( 'Posts' )

// then generate the URL thusly:
router.url({
  method:     "GET"
  controller: "Posts"
  action:     "show"
  id:         "123"
  format:     "json"
})
