router.resource 'Posts'
      .where
        id: /\d+/
      # nest on the member route
      .member ->
        @resource 'Comments'
