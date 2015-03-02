router.resource( 'Posts' )
      .where({
        id: /\d+/
      })
      // nest on the member route
      .member( function(){
        this.resource( 'Comments' )
      })
