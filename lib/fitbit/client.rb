require 'oauth2'
require 'base64'

module Fitbit
	module Client
		def self.pull_data(period)
			# TODO: select only users that have a flag set
			# User.where(fitbit_status: :fitbit_enabled)
			User.all.each do |user|
				refresh_access_token(user) do |token|
					update_profile(user, token, period)
				end
			end
		end

		private

		def self.update_profile(user, token, period)
			update_steps(user, token, period)
			update_calories(user, token, period)
			update_distance(user, token, period)
			update_sleep(user, token)
		end

		def self.update_calories(user, token, period)
			update_generic_param("calories", user, token, period)
		end

		def self.update_steps(user, token, period)
			update_generic_param("steps", user, token, period)
		end

		def self.update_distance(user, token, period)
			update_generic_param("distance", user, token, period)
		end

		def self.update_generic_param(param, user, token, period)
			path = "/1/user/-/activities/tracker/#{param}/date/today/#{period}.json"
			response = token.get(path)
			array = JSON.parse(response.body)["activities-tracker-#{param}"]
			pp array
			array.each do |row|
				log = user.daily_logs.where(date: row["dateTime"]).first_or_initialize
				log.send(param + "=", row["value"])
				log.save!
			end
		end

		def self.update_sleep(user, token)
			path = "/1.2/user/-/sleep/list.json?beforeDate=today&sort=desc&offset=0&limit=30"
			response = token.get(path)
			array = JSON.parse(response.body)["sleep"]
			array.each do |row|
				log = user.daily_logs.where(date: row["dateOfSleep"]).first_or_initialize
				log.sleep = row["duration"]
				log.save!
			end
		end

		def self.refresh_access_token(user, &block)
			client_id = '228M5L'
			client_secret = 'ecec79fbdfec04ba40ba419186a3b25d'
			redirect_uri = 'http://localhost:3000/users/auth/fitbit/callback'
			site = 'https://api.fitbit.com'
			client = OAuth2::Client.new(client_id, client_secret, site: site, authorize_url: '/oauth2/authorize', token_url: '/oauth2/token')
			secret = encode_secret(client_id, client_secret)
			token = OAuth2::AccessToken.from_hash(client, user.access_token)
			fresh_token = token.refresh!(headers: {'Authorization' => "Basic #{secret}"})
			user.access_token = fresh_token.to_hash
			user.save!
			block.call(fresh_token)
		end

		def self.encode_secret(client_id, client_secret)
			Base64.strict_encode64(client_id + ?: + client_secret)
		end
	end
end
