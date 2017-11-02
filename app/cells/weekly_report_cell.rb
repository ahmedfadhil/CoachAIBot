class WeeklyReportCell < Cell::ViewModel
	def show
		render
	end

	def begin_day
		Date.today.at_beginning_of_week
	end

	def end_day
		Date.today.at_end_of_week
	end

	def total_steps
		weekly_logs.map{ |e| e.steps }.inject(:+)
	end

	def total_distance
		weekly_logs.map{ |e| e.distance }.inject(:+)
	end

	def total_calories
		weekly_logs.map{ |e| e.calories }.inject(:+)
	end

	private

	def weekly_logs
		model.daily_logs.where("date >= ?", begin_day)
	end
end
