<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>Barista</title>

  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>

  <script src="http://cdnjs.cloudflare.com/ajax/libs/ace/1.1.3/ace.js" type="text/javascript" charset="utf-8"></script>
  <script src="prism.js"></script>
  <link rel="stylesheet" title="Default" href="prism.css" type='text/css'>
  <script type="text/coffeescript">
    $ ->
      $('#lang-select li a').on 'click', (evt)->
        $('body').attr 'data-lang', $(@).attr 'data-lang'
        $(@).closest('.dropdown').find('span.lang').text $(@).text()
      console.log 'lol'
  </script>

  <link href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
  <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
  <!-- <link href="http://maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet"> -->

  <link href='http://fonts.googleapis.com/css?family=Swanky+and+Moo+Moo' rel='stylesheet' type='text/css'>
  <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>

  <link rel="stylesheet" title="Default" href="screen.css" type='text/css'>

  <script src="http://coffeescript.org/extras/coffee-script.js"></script>
</head>
<body data-spy="scroll" data-target="#side-nav" data-lang='javascript'>

  <nav class="navbar navbar-default navbar-fixed-top" role="navigation">
    <div class="container">

      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="/">Barista</a>
      </div>



      <!-- Collect the nav links, forms, and other content for toggling -->
      <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
        <ul class="nav navbar-nav navbar-right">
          <li><a href="#docs">Documentation</a></li>
          <li><a href="#try">Demo</a></li>
          <li><a href="https://github.com/kieran/barista">Source</a></li>
          <li class="dropdown">
            <a class="dropdown-toggle" data-toggle="dropdown"><span class='lang'>Javascript</span> <span class="caret"></span></a>
            <ul id="lang-select" class="dropdown-menu" role="menu">
              <li><a data-lang="javascript">Javascript</a></li>
              <li><a data-lang="coffeescript">Coffeescript</a></li>
            </ul>
          </li>

        </ul>
      </div><!-- /.navbar-collapse -->


    </div>
  </nav>

  <div class="jumbotron" data-spy="affix" data-offset-top="450">
    <div class="container">
      <h1>Barista</h1>
      <p>A simple, powerful router<br/>for node.js and the browser</p>
      <p>
        <a href="#docs" class="btn btn-default" role="button">Github</a>
        <a href="https://www.npmjs.org/package/barista" class="btn btn-default" role="button">Npm</a>
      </p>
    </div>
  </div>

  <div class="container">
    <div id="docs" class="row">
      <div class="col-md-9">
        <div id="overview">
          <h2>Overview</h2>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent fermentum ut eros condimentum tempus. Fusce porttitor elit consectetur ullamcorper lacinia. Sed rutrum eu augue ut porttitor. Integer non fermentum felis. Etiam ullamcorper hendrerit gravida. Sed adipiscing pretium ligula ut consectetur. In venenatis ligula ac elit sollicitudin tempor. Cras a pellentesque dolor. Donec scelerisque quis massa dapibus eleifend.</p>
        </div>
        <div id="install">
          <h2>Install</h2>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent fermentum ut eros condimentum tempus. Fusce porttitor elit consectetur ullamcorper lacinia. Sed rutrum eu augue ut porttitor.
          <div id="install-node">
            <h3>Install via npm</h3>
            <code>npm install barista</code>
          </div>
          <div id="install-browser">
            <h3>Include the Browserify'd version</h3>
            <code>link tag goes here</code>
          </div>
        </div>

        <div id="routes">

          <h3>A simple example</h3>

          <pre class="language-javascript"><code>// a GET request to '/products'
router.match( '/products', 'GET' )
      .to( 'products.index' )

// =>
{
  controller: 'products',
  action: 'index',
  method: 'GET'
}</code></pre>
          <pre class="language-coffeescript"><code># a GET request to '/products'
router
.match '/products', 'GET'
.to 'products.index'
.where
  lol: /\w+/

# =>
{
  controller: 'products'
  action: 'index'
  method: 'GET'
}</code></pre>
        </div>

        <div id="lol2">
          <h2>lol 2</h2>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent fermentum ut eros condimentum tempus. Fusce porttitor elit consectetur ullamcorper lacinia. Sed rutrum eu augue ut porttitor. Integer non fermentum felis. Etiam ullamcorper hendrerit gravida. Sed adipiscing pretium ligula ut consectetur. In venenatis ligula ac elit sollicitudin tempor. Cras a pellentesque dolor. Donec scelerisque quis massa dapibus eleifend.</p>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent fermentum ut eros condimentum tempus. Fusce porttitor elit consectetur ullamcorper lacinia. Sed rutrum eu augue ut porttitor. Integer non fermentum felis. Etiam ullamcorper hendrerit gravida. Sed adipiscing pretium ligula ut consectetur. In venenatis ligula ac elit sollicitudin tempor. Cras a pellentesque dolor. Donec scelerisque quis massa dapibus eleifend.</p>
        </div>

        <div id="lol3">
          <h2>lol 3</h2>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent fermentum ut eros condimentum tempus. Fusce porttitor elit consectetur ullamcorper lacinia. Sed rutrum eu augue ut porttitor. Integer non fermentum felis. Etiam ullamcorper hendrerit gravida. Sed adipiscing pretium ligula ut consectetur. In venenatis ligula ac elit sollicitudin tempor. Cras a pellentesque dolor. Donec scelerisque quis massa dapibus eleifend.</p>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent fermentum ut eros condimentum tempus. Fusce porttitor elit consectetur ullamcorper lacinia. Sed rutrum eu augue ut porttitor. Integer non fermentum felis. Etiam ullamcorper hendrerit gravida. Sed adipiscing pretium ligula ut consectetur. In venenatis ligula ac elit sollicitudin tempor. Cras a pellentesque dolor. Donec scelerisque quis massa dapibus eleifend.</p>
        </div>

      </div>
      <div class="col-md-3">
        <div class="side-menu" data-spy="affix" data-offset-top="450" data-offset-bottom="200">

          <ul class="nav" id="side-nav">
            <li><a href="#overview" class="active">Overview</a></li>
            <li>
              <a href="#install">Installation</a>
              <ul class="nav">
                <li><a href="#install-node">Node JS</a></li>
                <li><a href="#install-browser">Browser</a></li>
              </ul>
            </li>
            <li>
              <a href="#routes">Routes</a></li>
              <ul class="nav">
                <li><a href="#routes-convenience">Convenience methods</a></li>
                <li><a href="#routes-variables">Variables</a></li>
                <li><a href="#routes-globs">Globs</a></li>
              </ul>
            <li><a href="#resources">Resources</a></li>
          </ul>

        </div>
      </div>
    </div>
  </div>


</body>
</html>
