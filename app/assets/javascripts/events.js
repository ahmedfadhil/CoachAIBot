function handleReminder(row) {
	
}

$( document ).ready(function() {
	$.getJSON("/events/reminders.json", function(result){
		var timeInSec = Date.now() / 1000;
		for (i = 0; i < result.length; i++) {
			//console.log(result[i]);
			var row = result[i]

			// if remind_at has expired
			if (row['remind_at'] <= timeInSec) {
				console.log('Event reminder has expired and will be notified')
				console.log(row)
			}
		}
	});
})
