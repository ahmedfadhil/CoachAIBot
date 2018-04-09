class WearableCell < Cell::ViewModel
	def card
		render
	end

	def title
		model.first_name + " " + model.last_name
	end


	def profile_image
		ChartDataBinder.new.profile_image_path(model)
	end

	def status
		if model.fitbit_disabled?
			css_class = "list-group-item list-group-item-danger"
			content_tag :li, "Integrazione disabilitata", class: css_class
		elsif model.fitbit_invited?
			css_class = "list-group-item list-group-item-warning"
			content_tag :li, "Invito inviato", class: css_class
		else # fitbit_enabled
			css_class = "list-group-item list-group-item-success"
			content_tag :li, "Integrazione abilitata", class: css_class
		end
	end

	def show_button
		if model.fitbit_enabled? && model.daily_logs.where("created_at >= ?", Time.zone.now.beginning_of_day).any?
			link_to "Mostra", show_wearable_path(model), class: 'btn btn-primary'
		else
			link_to "Mostra", show_wearable_path(model), class: 'btn btn-secondary disabled'
		end
	end

	def edit_button
		link_to "Modifica", edit_wearable_path(model), class: 'btn btn-warning'
	end
end
