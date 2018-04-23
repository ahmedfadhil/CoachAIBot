json.array! @events do |event|
  json.id event.id
  json.title event.title
  json.start event.start.to_i
  json.end event.end.to_i
	json.reminder_type event.reminder_type
	json.reminder_range event.reminder_range
	json.remind_at (event.start - event.reminder_range.send(event.reminder_type)).to_i
end
