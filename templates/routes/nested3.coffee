router
.get '/posts/:id(.:format)'
.to 'Posts.show'
.where # these conditions will apply to all sub-routes as well
  format: [
    'html'
    'pdf'
    'json'
  ]
.nest ->
  @get '/comments(.:format)'
  .to 'Comments.index'
