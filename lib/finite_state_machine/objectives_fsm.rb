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
					if dialog.current_objective_is_steps?
						@go_to_terminated = false
						@go_to_confirm_steps = true
					elsif dialog.current_objective_is_steps?
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
					dialog_transaction = DialogTransaction.new(text, type: :steps)
					if dialog_transaction.valid?
						dialog_transaction.run!
						@go_to_terminated = true
						return dialog_transaction.text_response
					else
						@go_to_terminated = false
						return dialog_transaction.text_response
					end
				end
			end

			state :confirm_distance do
				def dialog(text)
					@go_to_terminated = false
					# Not executed if validations fails
					DialogHelpers.validate_distance(text) do
						@go_to_terminated = true
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
		attr_reader :user

		def message_of_the_day
			response = {}
			response[:text] = ""
			response[:keyboard] = []
			if current_objective_is_steps?
				response[:text] = "Benvenuto utente, i tuoi obbiettivi sono PASSI"
				response[:keyboard] << 'Annulla'
			elsif current_objective_is_distance?
				response[:text] = "Benvenuto utente, i tuoi obbiettivi sono DISTANZA"
				response[:keyboard] << 'Annulla'
			else
				response[:text] = "Al momento non ci sono obbiettivi, riprova più tardi!"
				response[:keyboard] += ['Attivita', 'Feedback','Consigli','Messaggi','Obiettivi']
			end
			return response
		end

		def current_objective_is_distance?
			false
		end

		def current_objective_is_steps?
			false
		end

		def initialize(user)
			@user = user
		end
	end

	class DialogConfirmInput
		attr_reader :user, :type

		def dialog
			"bla.."
		end

		def initialize(hash)
			@user = hash[:user]
			@type = hash[:type]
		end
	end
end
