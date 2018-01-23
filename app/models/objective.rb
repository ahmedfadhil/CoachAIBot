class Objective < ApplicationRecord
	belongs_to :user
	has_many :objective_logs
	enum activity: { steps: 0, distance: 1 }
	enum fitbit_integration: { fitbit_disabled: 0, fitbit_enabled: 1 }

	validates :start_date, :end_date, presence: { message: 'Deve essere presente' }
	validate :start_and_end_date_must_be_consistent
	def start_and_end_date_must_be_consistent
		if !start_date.nil? && start_date < Date.today
			errors.add(:start_date, "Non può avere inizio nel passato")
		end

		return if start_date.nil? || end_date.nil?

		if start_date >= end_date
			errors.add(:start_date, "Deve iniziare prima della data di fine")
			errors.add(:end_date, "Deve finire dopo la data di inizio")
			return
		end

		days = TimeDifference.between(start_date, end_date).in_days
		if days < 10
			errors.add(:start_date, "la attività deve durare almeno 10 giorni")
			errors.add(:end_date, "La attività deve durare almeno 10 giorni")
		end

		user.objectives.each do |objective|
			next unless objective.persisted?
			next unless objective.id != id

			formatted_start_date = objective.start_date.strftime("%-d %B %Y")
			formatted_end_date = objective.end_date.strftime("%-d %B %Y")
			if start_date >= objective.start_date && start_date <= objective.end_date
				errors.add(:start_date, "Non può iniziare tra i giorni #{formatted_start_date} e #{formatted_end_date}")
			end
			if end_date >= objective.start_date && end_date <= objective.end_date
				errors.add(:end_date, "Non può terminare tra i giorni #{formatted_start_date} e #{formatted_end_date}")
			end
		end
	end

	validate :activity_must_have_attribute
	def activity_must_have_attribute
		if steps? && (steps.nil? || steps <= 0)
			errors.add(:steps, "Deve essere un numero intero positivo")
		elsif distance? && (distance.nil? || distance <= 0)
			errors.add(:distance, "Deve essere un numero intero positivo")
		end
	end

	def days
		TimeDifference.between(start_date, end_date).in_days.to_i
	end

	def daily_steps
		days = TimeDifference.between(start_date, end_date).in_days.to_i
		return steps / days
	end

	def daily_distance
		days = TimeDifference.between(start_date, end_date).in_days.to_i
		return distance / days
	end

	def daily_steps_progress
		days_obj = TimeDifference.between(start_date, end_date).in_days.to_i
		days_now = TimeDifference.between(start_date, Time.now).in_days.to_i
		days = [days_obj, days_now].min
		days = [days, 1].max
		return steps_progress / days
	end

	def daily_distance_progress
		days_obj = TimeDifference.between(start_date, end_date).in_days.to_i
		days_now = TimeDifference.between(start_date, Time.now).in_days.to_i
		days = [days_obj, days_now].min
		return steps_progress / days
	end

	def steps_progress
		if fitbit_enabled?
			steps_progress_fitbit
		else
			steps_progress_log
		end
	end

	def distance_progress
		if fitbit_enabled?
			distance_progress_fitbit
		else
			distance_progress_log
		end
	end

	def steps_progress_fitbit
		logs = user.daily_logs.select { |log|
			log.date <= end_date && start_date <= log.date
		}
		return logs.map{ |e| e.steps }.inject(:+) || 0
	end

	def distance_progress_fitbit
		logs = user.daily_logs.select { |log|
			log.date <= end_date && start_date <= log.date
		}
		return logs.map{ |e| e.distance }.inject(:+).floor(2) || 0
	end

	def distance_progress_log
		logs = objective_logs
		return (logs.map{ |e| e.distance }.inject(:+) || 0).floor(2)
	end

	def steps_progress_log
		logs = objective_logs
		return logs.map{ |e| e.steps }.inject(:+) || 0
	end
end
