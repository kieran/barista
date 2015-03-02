router.resource( 'Posts' )
      .where({
        id: /\d+/
      })
      // nest on the member route
      .collection( function(){
        this.get( '/like(.:format)' )
        .to( 'Posts.like' )
      })
