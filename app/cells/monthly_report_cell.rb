class MonthlyReportCell < Cell::ViewModel
	def show
		render
	end

	def chart
		render
	end

	def begin_day
		Date.today.beginning_of_month - 1.month
	end

	def end_day
		Date.today.end_of_month - 1.month
	end

	def begin_day_utc
		t = begin_day.to_time
		t += t.utc_offset
		return t = t.to_i * 1000
	end

	def steps_json
		JSON.generate(weekly_logs.map{ |e| e.steps })
	end

	def distance_json
		JSON.generate(weekly_logs.map{ |e| e.distance })
	end

	def calories_json
		JSON.generate(weekly_logs.map{ |e| e.calories })
	end

	def sleep_json
		JSON.generate(weekly_logs.map{ |e| e.sleep })
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
		weekly_logs.map{ |e| e.distance }.inject(:+).floor(2)
	end

	def daily_distance_average
		(total_distance / weekly_logs.length).floor(2)
	end

	def record_distance
		weekly_logs.max_by(&:distance).distance.floor(2)
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
		model.daily_logs.where("date >= ? AND date <= ?", begin_day, end_day)
	end

	def sleep_length
		weekly_logs.map { |e| e.sleep || 0 }.inject(:+) / 36000 / weekly_logs.length
	end
end
