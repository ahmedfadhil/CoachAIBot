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
			content_tag :li, "Wearable integration disabled", class: css_class
		elsif model.fitbit_invited?
			css_class = "list-group-item list-group-item-warning"
			content_tag :li, "Invite sent", class: css_class
		else # fitbit_enabled
			css_class = "list-group-item list-group-item-success"
			content_tag :li, "Wearable integration enabled", class: css_class
		end
	end

	def show_button
		if model.fitbit_enabled?
			link_to "Show", show_wearable_path(model), class: 'btn btn-primary'
		else
			link_to "Show", show_wearable_path(model), class: 'btn btn-secondary disabled'
		end
	end

	def edit_button
		link_to "Edit", edit_wearable_path(model), class: 'btn btn-warning'
	end
end
