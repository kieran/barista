$ ->
  $('body').on 'setlang', (evt, l)->
    $('body').attr 'data-lang', l.toLowerCase()
    $.cookie 'lang', l, expires: 365
    $('#lang-select').closest('.dropdown').find('span.lang').text l

  # set the default example language
  $('body').trigger 'setlang', $.cookie('lang') || 'Coffeescript' || 'Javascript'

  # set up lang switcher
  $('#lang-select li a').on 'click', (evt)->
    $('body').trigger 'setlang', $(@).text()

  setTimeout ->
    $('code span.token.string').each (id,el)->
      $(el).html(
        $(el).text()
        .replace(/(:\w+)/g,'<span class="barista_key">$1</span>')
        .replace(/(\*\w+)/g,'<span class="barista_glob">$1</span>')
      )
    $('#keys span.barista_key').addClass 'highlight'
    $('#globs span.barista_glob').addClass 'highlight'

  , 100

  $('a[href=#try]').on 'click', (evt, el=evt.target)->
    evt.preventDefault()
    $('body').toggleClass 'demo'
    $code = $(el).parent().find('code:first')
    if $code.length
      $('#demo input:first').val $code.data('url') || '/'
      window.editor.setValue $code.text().replace(/^\s+|\s+$/,''), -1
