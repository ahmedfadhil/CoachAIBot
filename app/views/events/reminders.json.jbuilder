json.array! @events do |event|
  date_format = '%Y-%m-%dT%H:%M:%S'
  json.id event.id
  json.title event.title
  json.start event.start.strftime(date_format)
  json.end event.end.strftime(date_format)
	json.reminder_type event.reminder_type
	json.reminder_range event.reminder_range
	json.remind_at (event.start - event.reminder_range.send(event.reminder_type)).strftime(date_format)
end
