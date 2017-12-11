class ObjectivesManager
	attr_reader :user, :state

	def initialize(user, user_state)
		@user = user
		@state = user_state
	end

	def dialog
		actuator = GeneralActions.new(@user, @state)
		actuator.send_reply 'Non hai nessun messaggio in attesa di essere letto.'
		actuator.back_to_menu_with_menu
	end
end
