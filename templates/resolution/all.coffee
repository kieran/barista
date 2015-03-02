# assuming the following route definition:
router.resource 'Posts'

# this URL (without a method) could match the following params:
router.all '/posts/123.json'
