router.resource( 'Posts' )
      .where({
        id: /\d+/
      })
      // nest on the collection route
      .collection( function(){
        this.get( '/recent(.:format)' )
        .to( 'Posts.recent' )
      })
