router
.get '/posts'
.to 'Posts.index'
.nest ->
  @get '/:id'
  .to 'Posts.show'
  .nest ->
    @get '/comments'
    .to 'Comments.index'
