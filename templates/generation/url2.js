// assuming the following route definition:
router.resource 'Posts'

// then generate the URL thusly:
params = {
  method:     "GET",
  controller: "Posts",
  action:     "show",
  id:         "123",
  format:     "json",
  love:       "cheese"
}

router.url( params, true )
