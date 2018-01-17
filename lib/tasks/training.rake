require 'bot/general_actions'

namespace :training do
	task :notify => :environment do
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
end
