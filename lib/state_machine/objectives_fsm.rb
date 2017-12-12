module StateMachine
	class ObjectivesFSM
		state_machine :state, initial: :initial do
			event :continue_dialog do
				transition initial: :terminated, if: :terminate_dialog?
				transition initial: :ask_steps, if: :ask_steps?
				transition initial: :ask_distance, if: :ask_distance?

				transition ask_steps: :terminated, if: :terminate_dialog?
				transition ask_steps: :confirm_steps, if: :steps_valid?
				transition ask_steps: same

				transition confirm_steps: :terminated, if: :confirm_steps_with_yes?
				transition confirm_steps: :ask_steps

				transition ask_distance: :terminated, if: :terminate_dialog?
				transition ask_distance: :confirm_distance, if: :distance_valid?
				transition ask_distance: same

				transition confirm_distance: :terminated, if: :confirm_distance_with_yes?
				transition confirm_distance: :ask_distance
			end

			state :initial do
				def dialog(text)
					@text = text
					text_buffer = ""
				end

				def terminate_dialog?
					false
				end

				def ask_steps?
					true
				end
			end

			state :ask_steps do
				def dialog(text)
					continue_dialog
					return "Quindi ha fatto NNN passi? Puoi confermarlo?"
				end

				def terminate_dialog?
					false
				end

				def steps_valid?
					true
				end
			end

			state :confirm_steps do
				def dialog(text)
					continue_dialog
					return "Molto bene! I dati che hai inserito saranno registrati..."
				end

				def confirm_steps_with_yes?
					true
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
