require 'action_view'

module FSM
	class ObjectivesFSM
		# The guy chatting with the finite state automa
		attr_reader :user

		attr_reader :go_to_terminated, :go_to_confirm_steps, :go_to_confirm_distance

		# read the ruby state_machine docs
		state_machine :state, initial: :message_of_the_day do
			event :continue_dialog do
				transition message_of_the_day: :terminated, if: :go_to_terminated
				transition message_of_the_day: :confirm_steps, if: :go_to_confirm_steps
				transition message_of_the_day: :confirm_distance, if: :go_to_confirm_distance

				transition confirm_steps: :terminated, if: :go_to_terminated
				transition confirm_steps: same # don't go anywere

				transition confirm_distance: :terminated, if: :go_to_terminated
				transition confirm_distance: same
			end

			state :message_of_the_day do
				def dialog(_ = nil)
					dialog = DialogMessageOfTheDay.new(user)
					if dialog.current_objective_is_steps? && user.fitbit_disabled?
						@go_to_terminated = false
						@go_to_confirm_steps = true
					elsif dialog.current_objective_is_distance? && user.fitbit_disabled?
						@go_to_terminated = false
						@go_to_confirm_steps = false
						@go_to_confirm_distance = true
					else
						@go_to_terminated = true
					end
					return dialog.message_of_the_day
				end
			end

			state :confirm_steps do
				def dialog(text)
					dialog = DialogConfirmActivity.new(user: user, text: text, activity: :steps)
					if dialog.valid?
						dialog.commit!
						@go_to_terminated = true
						return dialog.response
					elsif dialog.abort?
						@go_to_terminated = true
						return dialog.response
					else
						@go_to_terminated = false
						return dialog.response
					end
				end
			end

			state :confirm_distance do
				def dialog(text)
					dialog = DialogConfirmActivity.new(user: user, text: text, activity: :distance)
					if dialog.valid?
						dialog.commit!
						@go_to_terminated = true
						return dialog.response
					elsif dialog.abort?
						@go_to_terminated = true
						return dialog.response
					else
						@go_to_terminated = false
						return dialog.response
					end
				end
			end

			state :terminated do
				def dialog(text)
					raise StandardError.new("Dialog is terminated")
				end
			end
		end

		def update_model!(model)
			model[:objectives_state] = state
		end

		def self.from_model(user, model)
			obj = new(user)
			obj.state = model[:objectives_state]
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
				response[:keyboard] << 'Annulla'
			else
				response[:text] << "I tuoi progressi saranno monitorati tramite il tuo braccialetto contapassi, "
				response[:text] << "quindi ricordarti di sincronizzare il dispositivo quando possibile."
				response[:keyboard] += ['Attivita', 'Feedback','Consigli','Messaggi','Obiettivi']
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
			response[:keyboard] += ['Attivita', 'Feedback','Consigli','Messaggi','Obiettivi']
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
end
