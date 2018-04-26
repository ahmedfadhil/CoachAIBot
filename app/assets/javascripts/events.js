if (typeof(Storage) !== "undefined") {
	 // Code for localStorage/sessionStorage.
	 console.log('Your browser is up-to-date!')
} else {
	 // Sorry! No Web Storage support..
	 console.log('Please update your browser!')
}


function trigger(result) {
	console.log('trigger function');
	checkForExpired(result);
	setTimeout(function(){ trigger(result) }, 30000);
}

// check for expired reminders
function checkForExpired(result) {
	var playSound = false;
	var timeInSec = Date.now() / 1000;
	for (i = 0; i < result.length; i++) {
		//console.log(result[i]);
		var row = result[i];

		// if remind_at has expired
		if (row['remind_at'] <= timeInSec) {
			console.log('Event reminder has expired, handling event');
			console.log(row);

			if (handleReminder(row)) {
				playSound = true;
			}
		}
	}

	if (playSound) {
		if (localStorage['sound_played_at'] === undefined) {
			playSoundLight()
		} else {
			var sound_played_at = Number(localStorage['sound_played_at']);
			var timeInSec = Date.now() / 1000;
			var delta = 60*10;
			if (sound_played_at + delta < timeInSec) {
				playSoundLight();
			}
		}
	}
}

function playSoundLight() {
	console.log('playing sound');
	var audio = new Audio('/assets/light.mp3');
	audio.play();
	localStorage['sound_played_at'] = Date.now() / 1000;
}

function handleReminder(row) {
	var alertShown = false;
	var id = row['id'];


	if (localStorage['reminders_' + id] === undefined) {
		console.log('I shall notify the user!');
		alertShown = showAlert(row);
	} else if (localStorage['reminders_' + id] !== 'true') {
		console.log('I shall notify the user again, only if the timer has expired');
		var timeout = Number(localStorage['reminders_' + id]);
		var timeInSec = Date.now() / 1000;
		if (timeout < timeInSec) {
			alertShown = showAlert(row);
		}
	}

	return alertShown;
}

function createAlert(row) {
	var timeInSec = Date.now() / 1000;
	var tag;
	var mark = $('<button>').attr('class','btn btn-primary btn-sm btn-mark').text('Marca come letto');
	mark.attr('data-toogle','tooltip').attr('data-placement','top').attr('title','Nascondi per sempre questo messaggio');
	mark.tooltip();
	mark.click(function(e) {
		tag.remove();
		localStorage['reminders_' + row['id']] = true;
	})

	var snooze = $('<button>').attr('class','btn btn-secondary btn-sm btn-snooze').text('Postponi');
	snooze.attr('data-toogle','tooltip').attr('data-placement','top').attr('title','Ti ricorderó piu` tardi di questo evento');
	snooze.tooltip();
	var map = {'minutes': 60, 'hours': 60*60, 'days': 60*60*24};
	snooze.click(function(e) {
		tag.remove();
		reminder_timestap = timeInSec + map[row['reminder_type']];
		localStorage['reminders_' + row['id']] = reminder_timestap
	});
	if ((timeInSec + map[row['reminder_type']]) > row['start']) {
		//snooze.disable();
		snooze.hide();
	}

	tag = $("<div>").attr("class","alert alert-success").attr('role','alert').append(
		$('<h4>').attr('class','alert-heading').text('Attenzione!'),
		$('<p>').text('Event title: ' + row['title']),
		mark,
		snooze,
	);
	return tag;
}

function showAlert(row) {
	var alertFound = false;
	$('div.alert').each(function() {
		var data = $(this).data();
		if (data['id'] == row['id']) {
			alertFound = true;
		}
	});
	if (alertFound) {
		return false;
	}

	var tag = createAlert(row);
	tag.prependTo($('#main-container'));
	tag.data(row);
	return true
}

$( document ).ready(function() {
	$.getJSON("/events/reminders.json", function(result){
		trigger(result);
	});
});
