class WearableCell < Cell::ViewModel
	def card
		render
	end

	def title
		model.first_name + " " + model.last_name
	end

	def status
		if model.fitbit_disabled?
			css_class = "list-group-item list-group-item-danger"
			content_tag :li, "Integration disabled", class: css_class
		elsif model.fitbit_invited?
			css_class = "list-group-item list-group-item-warning"
			content_tag :li, "Invite sent", class: css_class
		else # fitbit_enabled
			css_class = "list-group-item list-group-item-success"
			content_tag :li, "Integration enabled", class: css_class
		end
	end
end
