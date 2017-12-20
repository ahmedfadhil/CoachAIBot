require 'action_view'

module FSM
	class ObjectivesFSM
		attr_reader :user
		attr_accessor :input
		attr_reader :text

		state_machine :state, initial: :message_of_the_day do
			event :continue_dialog do
				transition message_of_the_day: :read_input
				transition read_input: :confirm_input
				transition confirm_input: :terminated
			end

			event :repeat_dialog do
				transition read_input: same
				transition confirm_input: same
			end

			event :undo_dialog do
				transition confirm_input: :read_input
			end

			event :terminate_dialog do
				transition any => :terminated
			end

			state :message_of_the_day do
				def talk(_ = nil)
					dialog = DialogMessageOfTheDay.new(user)
					return dialog.message_of_the_day
				end

				def advance_state
					dialog = DialogMessageOfTheDay.new(user)
					if dialog.current_objective_is_steps? && user.fitbit_disabled?
						continue_dialog
					elsif dialog.current_objective_is_distance? && user.fitbit_disabled?
						continue_dialog
					else
						terminate_dialog
					end
				end
			end

			state :read_input do
				def talk(text)
					@input = text
					dialog = DialogReadInput.new(user, text)
					return dialog.talk
				end

				def advance_state
					dialog = DialogReadInput.new(user, input)
					if dialog.valid?
						continue_dialog
					elsif dialog.abort?
						terminate_dialog
					else
						repeat_dialog
					end
				end
			end

			state :confirm_input do
				def talk(text)
					@text = text
					dialog = DialogConfirmInput.new(user, input, text)
					return dialog.talk
				end

				def advance_state
					dialog = DialogConfirmInput.new(user, input, text)
					if dialog.yes?
						dialog.commit!
						terminate_dialog
					elsif dialog.no?
						undo_dialog
					else
						repeat_dialog
					end
				end
			end
		end

		def update_model!(model)
			model['objectives_state'] = state
			model['objectives_input'] = input
		end

		def self.from_model(user, model)
			obj = new(user)
			obj.state = model['objectives_state']
			obj.input = model['objectives_input']
			return obj
		end

		def initialize(user)
			@user = user
			super() # NOTE: This *must* be called, otherwise states won't get initialized
		end
	end

	class DialogMessageOfTheDay
		include ActionView::Helpers::TranslationHelper

		attr_reader :user

		def message_of_the_day
			response = {}
			response[:text] = ""
			response[:keyboard] = []
			if user.active_objective
				motd_for_current_objective(response)
			else
				motd_for_future_objectives(response)
			end
			return response
		end

		def motd_for_current_objective(response)
			objective = user.active_objective
			start_date = l(objective.start_date, format: "%-d %B %Y")
			end_date = l(objective.end_date, format: "%-d %B %Y")
			if current_objective_is_steps?
				objective = user.active_objective
				response[:text] << "Benvenuto utente, al momento il tuo obiettivo e' totalizzare #{objective.steps} passi, "
			elsif current_objective_is_distance?
				response[:text] << "Benvenuto utente, al momento il tuo obiettivo e' percorrere #{objective.distance} km a piedi, "
			end
			response[:text] << "entro il giorno #{end_date}. "
			if objective.steps?
				response[:text] << "Dovrai totalizzare #{objective.steps} passi in #{objective.days} giorni, "
				response[:text] << "la media giornaliera di passi da compiere sara' #{objective.daily_steps}. "
			else
				response[:text] << "Dovrai totalizzare #{objective.distance} km a piedi, "
				response[:text] << "la media giornaliera di km da percorrere sara' #{objective.daily_distance}. "
			end

			if user.fitbit_disabled?
				response[:text] << "Se desideri puoi comunicarmi adesso i tuoi progressi, oppure usa il bottone ANNULLA per tornare al menu' principale"
				response[:keyboard] << ['Annulla']
			else
				response[:text] << "I tuoi progressi saranno monitorati tramite il tuo braccialetto contapassi, "
				response[:text] << "quindi ricordarti di sincronizzare il dispositivo quando possibile."
				response[:keyboard] += [['Attivita', 'Feedback'],['Consigli','Messaggi'],['Obiettivi']]
			end
		end

		def motd_for_future_objectives(response)
			response[:text] << "Al momento non ci sono obiettivi attivi. "
			if user.scheduled_objectives.any?
				scheduled_objective = user.scheduled_objectives.first
				start_date = l(scheduled_objective.start_date, format: "%-d %B %Y")
				end_date = l(scheduled_objective.end_date, format: "%-d %B %Y")
				response[:text] << "Il prossimo obiettivo in programma per te avra' inizio il giorno #{start_date} "
				response[:text] << "e avra' termine il giorno #{end_date}. "
				if scheduled_objective.steps?
					response[:text] << "Dovrai totalizzare #{scheduled_objective.steps} passi in #{scheduled_objective.days} giorni, "
					response[:text] << "la media giornaliera di passi da compiere sara' #{scheduled_objective.daily_steps}. "
				else
					response[:text] << "Dovrai totalizzare #{scheduled_objective.distance} km a piedi, "
					response[:text] << "la media giornaliera di km da percorrere sara' #{scheduled_objective.daily_distance}. "
				end
				if user.fitbit_disabled?
					response[:text] << "Potrai registrare i tuoi progressi accedendo a questo stesso menu, "
					response[:text] << "per tenere traccia dei tuoi progressi utilizza un dispositivo contapassi!"
				else
					response[:text] << "I tuoi progressi saranno monitorati tramite il tuo braccialetto contapassi, "
					response[:text] << "quindi ricordarti di sincronizzare il dispositivo quando possibile."
				end
				response[:text] << "A presto!"
			else
				response[:text] << "Ripassa piu' tardi!"
			end
			response[:keyboard] += [['Attivita', 'Feedback'],['Consigli','Messaggi'],['Obiettivi']]
		end

		def current_objective_is_distance?
			user.active_objective && user.active_objective.distance?
		end

		def current_objective_is_steps?
			user.active_objective && user.active_objective.steps?
		end

		def initialize(user)
			@user = user
		end
	end

	class DialogReadInput
		attr_reader :user, :text

		def abort?
			!!(/annulla/i =~ text)
		end

		def valid?
			activity = user.active_objective.activity
			if activity == "steps"
				!!(/^(\d+)\s*(?:passi)?$/i =~ text)
			elsif activity == "distance"
				!!(/^(\d+(?:(?:,|.)\d+)?)\s*(?:km)?$/i =~ text)
			end
		end

		def talk
			response = {}
			response[:text] = ""
			response[:keyboard] = []
			if valid?
				response_valid(response)
			elsif abort?
				response_abort(response)
			else
				response_malformed(response)
			end
			return response
		end

		def response_valid(response)
			response[:text] << "OK. Perfavore ricontrolla il dato che hai inserito e verifica che sia corretto"
			response[:keyboard] << ['Si'] << ['No']
		end

		def response_abort(response)
			response[:text] << "OK. Ripassa quando vuoi"
			response[:keyboard] << ['Attivita', 'Feedback'] << ['Consigli','Messaggi'] << ['Obiettivi']
		end

		def response_malformed(response)
			response[:text] << "Non ho capito, potresti ripetere perfavore?"
			response[:keyboard] << ['Annulla']
		end

		def initialize(user, text)
			@user = user
			@text = text
		end
	end

	class DialogConfirmInput
		attr_reader :user, :text, :input

		def yes?
			!!(/si/i =~ text)
		end

		def no?
			!!(/no/i =~ text)
		end

		def commit!
			# nothign to do yet!
		end

		def talk
			response = {}
			response[:text] = ""
			response[:keyboard] = []

			if yes?
				response_yes(response)
			elsif no?
				response_no(response)
			else
				response_malformed(response)
			end

			return response
		end

		def response_yes(response)
			response[:text] << "Molto bene. Il dato che hai inserito e' stato salvato"
			response[:keyboard] += [['Attivita', 'Feedback'],['Consigli','Messaggi'],['Obiettivi']]
		end

		def response_no(response)
			response[:text] << "OK. Digita il dato che desideri salvare"
			response[:keyboard] << ['Annulla']
		end

		def response_malformed(response)
			response[:text] << "Non ho capito, vuoi registrare il dato che hai inserito?"
			response[:keyboard] << ['Si'] << ['No']
		end

		def initialize(user, input, text)
			@user = user
			@input = input
			@text = text
		end
	end
end
