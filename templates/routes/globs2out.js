router.first( '/somewhere/that/404s.html', 'GET' );

// =>
{
  controller: 'Errors',
  action: 'notFound',
  path: '/somewhere/that/404s',
  method: 'GET',
  format: 'html'
}
