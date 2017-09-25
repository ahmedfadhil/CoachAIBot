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

		def update_profile(user, token)
			raise "ROLLING"
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
			block.call(fresh_token)
			user.access_token = fresh_token.to_hash
			user.save!
		end

		def self.encode_secret(client_id, client_secret)
			Base64.strict_encode64(client_id + ?: + client_secret)
		end
	end
end
