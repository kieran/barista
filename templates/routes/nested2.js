router.get( '/products/:id' )
      .to( 'Products.show', { display: 'main' } )
      .nest( function(){
        this.get( '/reviews' )
            .to( 'Reviews.index', { display: 'alt' } )
      })
