router.get( '/posts' )
      .to( 'Posts.index' )
      .nest( function(){
        this.get( '/:id' )
            .to( 'Posts.show' )
            .nest( function(){
              this.get( '/comments' )
                  .to( 'Comments.index' )
            })
      })
