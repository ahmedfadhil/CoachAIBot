require 'bot/general_actions'

def notify_new
	User.all.each do |user|
		message1 = "FIXME"
		obj = user.active_objective
		#if obj && obj.start_date == Date.today
		if obj
			message1 = "Salve! Oggi ha inizio un nuovo programma di allenamento che e' stato impostato dal coach! Naviga nella sezione OBIETTIVI per ottenere ulteriori informazioni"
			ga = GeneralActions.new(user, JSON.parse(user.bot_command_data))
			ga.send_reply(message1)
		end
	end
end

def notify_completed
	User.all.each do |user|
		message1 = "FIXME"
		obj = user.active_objective
		if obj
			if obj.steps?
				if obj.steps <= obj.steps_progress
					message1 = "Congratulazioni #{user.first_name}, hai superato il programma di allenamento che ti e' stato assegnato dal coach! "
					message1 << "Il numero di passi presvisti era #{obj.steps}, i passi che hai effettuato sono #{obj.steps_progress}. "
				else
					message1 = "#{user.first_name}, il programma di allenamento che ti e' stato assegnato dal coach non e' stato superato. "
					message1 << "Il numero di passi presvisti era #{obj.steps}, i passi che hai effettuato sono #{obj.steps_progress}. "
				end
			elsif obj.distance?
				if obj.distance <= obj.distance_progress
					message1 = "Congratulazioni #{user.first_name}, hai superato il programma di allenamento che ti e' stato assegnato dal coach! "
					message1 << "La distanza a piedi presvisti era #{obj.distance} km, la distanza che hai effettivamente percorso e' stata #{obj.distance_progress}. "
				else
					message1 = "#{user.first_name}, il programma di allenamento che ti e' stato assegnato dal coach non e' stato superato. "
					message1 << "La distanza a piedi presvisti era #{obj.distance} km, la distanza che hai effettivamente percorso e' stata #{obj.distance_progress}. "
				end
			end
		end
		message1 << "Invia un messaggio al coach dalla sezione Messaggi se desideri discutere con il coach del risultato di questo programma di allenamento. Grazie"
		ga = GeneralActions.new(user, JSON.parse(user.bot_command_data))
		ga.send_reply(message1)
	end
end

namespace :training do
	task :notify_new => :environment do
		notify_new
	end

	task :notify_completed => :environment do
		notify_completed
	end
end
