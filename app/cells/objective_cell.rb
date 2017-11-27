class ObjectiveCell < Cell::ViewModel
	include ActionView::Helpers::TranslationHelper

	def table
		render
	end

	def row
		render
	end

	def active?
		model.start_date <= Date.today && Date.today <= model.end_date
	end

	def scheduled?
		model.start_date >= Date.today
	end

	def terminated?
		model.end_date < Date.today
	end

	def daily_steps
		if model.monthly?
			model.steps / 28
		elsif model.weekly?
			model.steps / 7
		end
	end

	def total_steps
		days = TimeDifference.between(model.start_date, model.end_date).in_days.to_i
		return daily_steps * days
	end

	def daily_distance
		if model.monthly?
			model.steps / 28
		elsif model.weekly?
			model.steps / 7
		end
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
