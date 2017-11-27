class ObjectiveCell < Cell::ViewModel
	include ActionView::Helpers::TranslationHelper 

	def table
		render
	end

	def row
		render
	end

	def scheduler
		if model.monthly?
			"Mensile"
		elsif model.weekly?
			"Settimanale"
		end
	end

	def activity
		if model.steps?
			"Passi"
		elsif model.distance?
			"Distanza"
		end
	end

	def quantity
		if model.steps?
			model.steps
		elsif model.distance?
			"#{model.distance} Km"
		end
	end

	def formatted_start_date
		l(model.start_date, format: "%-d %B %Y")
	end

	def formatted_end_date
		l(model.end_date, format: "%-d %B %Y")
	end
end
