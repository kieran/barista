router
.get '/posts/:id'
.to 'Posts.show', display: 'main'
.nest ->
  @get '/comments'
  .to 'Comments.index', display: 'alt'
