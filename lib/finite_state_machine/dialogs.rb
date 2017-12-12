module FSM
	class DialogMessageOfTheDay
		attr_reader :user

		def dialog
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
				response[:text] = "Al momento non ci sono obbiettivi"
			end
		end

		def current_objective_is_distance?
			true
		end

		def current_objective_is_steps?
			true
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
