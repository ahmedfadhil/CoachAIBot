namespace :fitbit do
	task :scramble => :environment do
		puts "They see me rolling"
		DailyLog.all.each do |log|
			log.steps = Random.rand(10000)
			log.distance = Random.rand(500000) / 100000.0
			log.calories = Random.rand(4000)
			log.sleep = Random.rand(8 * 60 * 60 * 1000)
			log.save!
		end
	end
end
