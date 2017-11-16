class ObjectiveCell < Cell::ViewModel
	def table
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
		model.start_date.strftime("%-d %B %Y")
	end

	def formatted_end_date
		model.end_date.strftime("%-d %B %Y")
	end
end
