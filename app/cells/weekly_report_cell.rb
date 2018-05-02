class WeeklyReportCell < Cell::ViewModel
	include ActionView::Helpers::TranslationHelper

	def show
		render
	end

	def chart
		render
	end

	def navigation
		render
	end

	def nav_item(str, path, tab)
		if tab == @options[:tab]
			link_to str, path, class: "nav-link active"
		else
			link_to str, path, class: "nav-link"
		end
	end

	def begin_day
		Date.today.at_beginning_of_week - 7.days
	end

	def begin_day_utc
		t = begin_day.to_time
		t += t.utc_offset
		return t = t.to_i * 1000
	end

	def steps_json
	rescue 		JSON.generate(weekly_logs.map{ |e| e.steps })
	end

	def distance_json
	rescue 	JSON.generate(weekly_logs.map{ |e| e.distance })
	end

	def calories_json
	rescue 	JSON.generate(weekly_logs.map{ |e| e.calories })
	end

	def sleep_json
	rescue 	JSON.generate(weekly_logs.map{ |e| e.sleep })
	end

	def end_day
	rescue 	Date.today.at_end_of_week - 7.days
	end

	def most_active_day
		rescue l(weekly_logs.max_by(&:calories).date,  format: "%A %d %B")
	end

	def least_active_day
	rescue l(weekly_logs.min_by(&:calories).date, format: "%A %d %B")
	end

	def total_steps
	rescue 	weekly_logs.map{ |e| e.steps }.inject(:+)
	end

	def daily_steps_average
	rescue 	total_steps / weekly_logs.length
	end

	def record_steps
	rescue 	weekly_logs.max_by(&:steps).steps
	end

	def total_distance
	rescue 	weekly_logs.map{ |e| e.distance }.inject(:+).floor(2)
	end

	def daily_distance_average
	rescue 	(total_distance / weekly_logs.length).floor(2)
	end

	def record_distance
	rescue 	weekly_logs.max_by(&:distance).distance.floor(2)
	end

	def total_calories
	rescue 	weekly_logs.map{ |e| e.calories }.inject(:+)
	end

	def daily_calories_average
	rescue 	total_calories / weekly_logs.length
	end

	def record_calories
	rescue 	weekly_logs.max_by(&:calories).calories
	end

	def sleep_length_h
	rescue 	sleep_length / 60
	end

	def sleep_length_min
	rescue 	sleep_length % 60
	end

	private

	def weekly_logs
	rescue 	model.daily_logs.where("date >= ? AND date <= ?", begin_day, end_day)
	end

	def sleep_length
	rescue 	weekly_logs.map { |e| e.sleep || 0 }.inject(:+) / 36000 / weekly_logs.length
	end
end
