router.first '/timezones/America/Toronto', 'GET'

# =>
{
  controller: 'Timezones'
  action: 'select'
  tzname: 'America/Toronto'
  method: 'GET'
}
