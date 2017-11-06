class MonthlyReportCell < Cell::ViewModel
	def show
		render
	end

	def begin_day
		Date.today.beginning_of_month
	end

	def end_day
		Date.today.end_of_month
	end

	def most_active_day
		weekly_logs.max_by(&:calories).date.strftime("%A %d %B")
	end

	def least_active_day
		weekly_logs.min_by(&:calories).date.strftime("%A %d %B")
	end

	def total_steps
		weekly_logs.map{ |e| e.steps }.inject(:+)
	end

	def daily_steps_average
		total_steps / weekly_logs.length
	end

	def record_steps
		weekly_logs.max_by(&:steps).steps
	end

	def total_distance
		weekly_logs.map{ |e| e.distance }.inject(:+)
	end

	def daily_distance_average
		total_distance / weekly_logs.length
	end

	def record_distance
		weekly_logs.max_by(&:distance).distance
	end

	def total_calories
		weekly_logs.map{ |e| e.calories }.inject(:+)
	end

	def daily_calories_average
		total_calories / weekly_logs.length
	end

	def record_calories
		weekly_logs.max_by(&:calories).calories
	end

	def sleep_length_h
		sleep_length / 60
	end

	def sleep_length_min
		sleep_length % 60
	end

	private

	def weekly_logs
		model.daily_logs.where("date >= ?", begin_day)
	end

	def sleep_length
		weekly_logs.map { |e| e.sleep || 0 }.inject(:+) / weekly_logs.length
	end
end
