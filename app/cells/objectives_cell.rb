require 'modules/chart_data_binder'

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

	def table
		render
	end

	def profile_image
		ChartDataBinder.new.profile_image_path(model)
	end

	def objective
		@options[:objective]
	end

	def objectives
		@options[:objectives]
	end

	def errors_for(model, field)
		if model.errors.include? field
			message = model.errors[field].map { |e| e + "<br>"}.join
			content_tag :div, message, class: "invalid-feedback", style: "display: block"
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
		if !model.active_objective.nil?
			css_class = "list-group-item list-group-item-success"
			content_tag :li, "Allenamento avviato", class: css_class
		elsif model.scheduled_objectives.any?
			css_class = "list-group-item list-group-item-warning"
			content_tag :li, "Allenamento programmato", class: css_class
		else
			css_class = "list-group-item list-group-item-danger"
			content_tag :li, "Nessun allenamento programmato", class: css_class
		end
	end

	def show_button
		link_to "Mostra", user_objectives_path(model), class: 'btn btn-primary'
	end
end
