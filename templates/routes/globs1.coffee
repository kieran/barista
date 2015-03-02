router
.match '/timezones/*tzname', 'GET'
.to 'Timezones.select'
