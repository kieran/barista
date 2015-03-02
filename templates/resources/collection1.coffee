router.resource 'Posts'
      .where
        id: /\d+/
      # nest on the collection route
      .collection ->
        @get '/recent(.:format)'
        .to 'Posts.recent'
