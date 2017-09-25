require 'fitbit/client'
namespace :fitbit do
	desc 'pull data from the fitbit cloud for all the authenticated users'
	task :pull_data => :environment do
		puts "They see me rolling"
		Fitbit::Client.pull_data
	end
end
