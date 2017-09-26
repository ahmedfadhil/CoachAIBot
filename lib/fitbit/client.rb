require 'oauth2'
require 'base64'

module Fitbit
	module Client
		def self.pull_data
			# TODO: select only users that have a flag set
			# User.where(fitbit_status: :fitbit_enabled)
			User.all.each do |user|
				refresh_access_token(user) do |token|
					update_profile(user, token)
				end
			end
		end

		private

		def self.update_profile(user, token)
			date = Time.now
			today = "#{date.year.to_s}-#{date.month.to_s}-#{date.day.to_s}" #"2017-09-25"
			#pp JSON.parse(token.get("/1/user/-/activities/tracker/steps/date/today/1d.json").body)
			#pp JSON.parse(token.get("/1/user/-/activities/tracker/calories/date/today/1d.json").body)
			#pp JSON.parse(token.get("/1/user/-/activities/tracker/distance/date/today/1d.json").body)

			response = token.get("/1.2/user/-/sleep/list.json?beforeDate=today&offset=0&limit=100&sort=asc")
			pp response
			pp JSON.parse(response.body)
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
