router.resource 'Posts'
      .where
        id: /\d+/
      # nest on the member route
      .member ->
        @get '/like(.:format)'
        .to 'Posts.like'
