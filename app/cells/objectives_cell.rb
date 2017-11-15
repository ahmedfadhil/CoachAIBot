class ObjectivesCell < Cell::ViewModel
	include ActionView::Helpers::FormOptionsHelper

	def show
		render
	end

	def card
		render
	end

	def new
		render
	end

	def objective
		@options[:objective]
	end

	def errors_for(model, field)
		if model.errors.include? field
			content_tag :div, model.errors[field].first, class: "invalid-feedback", style: "display: block"
		end
	end

	def class_for(model, field)
		if model.errors.include? field
			"form-control is-invalid"
		else
			"form-control"
		end
	end

	def title
		model.first_name + " " + model.last_name
	end

	def status
		if model.objectives.any?
			css_class = "list-group-item list-group-item-success"
			content_tag :li, "Obiettivo attivato", class: css_class
		elsif model.objectives.any?
			css_class = "list-group-item list-group-item-warning"
			content_tag :li, "Obiettivo programmato", class: css_class
		else
			css_class = "list-group-item list-group-item-danger"
			content_tag :li, "Nessun obiettivo programmato", class: css_class
		end
	end

	def show_button
		link_to "Mostra", user_objectives_path(model), class: 'btn btn-primary'
	end

	private

	def active_objective?
		model.objectives.any? do |objective|
			objective.start_date <= Date.today && Date.today <= objective.end_date
		end
	end

	def scheduled_objective?
		model.objectives.any? do |objective|
			objective.start_date >= Date.today
		end
	end

end
