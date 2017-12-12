require 'ostrcut'

module FSM
	class ObjectivesFSM
		# The guy chatting with the finite state automa
		attr_reader user

		# read the ruby state_machine docs
		state_machine :state, initial: :message_of_the_day do
			event :continue_dialog do
				transition message_of_the_day: :terminated, if: :go_to_terminated?
				transition message_of_the_day: :confirm_steps, if: :go_to_confirm_steps?
				transition message_of_the_day: :confirm_distance, if: :go_to_confirm_distance?

				transition confirm_steps: :terminated, if: :go_to_terminated?
				transition confirm_steps: same # don't go anywere

				transition confirm_distance: :terminated, if: :go_to_terminated?
				transition confirm_distance: same
			end

			state :message_of_the_day do
				def dialog(_ = nil)
					@go_to_terminated 				= true
					@go_to_confirm_steps 			= false
					@go_to_confirm_distance 	= false
					if DialogHelpers.current_objective_is_steps?
						@go_to_terminated 				= false
						@go_to_confirm_steps 			= true
						@go_to_confirm_distance 	= false
					elsif DialogHelpers.current_objective_is_steps?
						@go_to_terminated 				= false
						@go_to_confirm_steps 			= false
						@go_to_confirm_distance 	= true
					end
					return DialogHelpers.message_of_the_day
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

		def initialize(user)
			@user = user
			super() # NOTE: This *must* be called, otherwise states won't get initialized
		end
	end
end
