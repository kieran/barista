$ ->
  $tbl = $ '#demo table'
  # window.$ta = $textarea = $ '<textarea/>'
  $input = $ '#demo input:first'
  $select = $ '#demo select:first'

  $('#routeFile').text $('#routeFile').text().replace /^\s+/, ''

  window.editor = editor = ace.edit "routeFile"
  editor.setTheme "ace/theme/chrome"
  editor.getSession().setMode "ace/mode/coffee"
  editor.getSession().setTabSize 2
  editor.getSession().setUseSoftTabs true
  editor.setHighlightActiveLine false
  # editor.renderer.setShowGutter false
  editor.setOptions maxLines: Infinity, minLines: 20

  editor.getSession().on 'change', -> recalcRoutes()

  $('body').on 'setlang', (evt, l)->
    modes =
      coffeescript: 'coffee'
      javascript: 'javascript'
    editor.getSession().setMode "ace/mode/#{modes[l.toLowerCase()]}"
    editor.resize()


  # $textarea.val(editor.getValue()).trigger('change')

  $input.on 'keyup change', -> recalcRoutes()
  $select.on 'keyup change', -> recalcRoutes()

  router = undefined
  curRouter = undefined

  recalcRoutes = (code)->
    code ?= editor.getValue()

    try
      code = CoffeeScript.compile code, bare: on

    curRouter ?= new Barista

    try
      router = (new Function('router', "#{code};return router"))(new Barista)

    return unless router && curRouter = router

    window.lol = router

    method = $select.val() || undefined
    url = $input.val()

    firstMatchParams = curRouter.first( url, method ) || undefined

    $('#demo table').replaceWith $tbl = $ "<table class='table table-condensed #{'with-matches' if firstMatchParams}'/>"

    for route in curRouter.routes
      console.log route
      params = route.parse.call route, url, method
      $tbl.append $ """
        <tr class="#{if params then 'success'}">
          <td class="method">
            #{route.method || ''}
          </td>
          <td class="route">
            #{route}
          </td>
          <td class="params">#{if params then JSON.stringify(params, null, '  ') else ''}</td>
          <td class="name">
            #{route.route_name || ''}
          </td>
        </tr>
      """
  recalcRoutes()
