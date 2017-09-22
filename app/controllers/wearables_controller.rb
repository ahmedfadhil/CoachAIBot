require 'oauth2'
require 'base64'

class WearablesController < ApplicationController
	def connect
		token = params[:token]
		user = User.where(identity_token: token).first
		unless user.nil?
			# give the user a cookie with his user id
			cookies[:user_id] = user.id

			# XXX move into .env file
			client_id = '228MKX'
			client_secret = 'd17e91ecd2045b664d5bf9a8c7a6f0bc'
			redirect_uri = 'https://9fbafaa0.ngrok.io/users/auth/fitbit/callback'

			# make sure you point the client to /oauth2/authorize otherwise it won't work!
			client = OAuth2::Client.new(client_id, client_secret, site: 'https://www.fitbit.com', authorize_url: '/oauth2/authorize')
			url = client.auth_code.authorize_url(redirect_uri: redirect_uri) + "&scope=activity%20sleep"
			redirect_to url
		else
			raise "Invalid identity_token"
		end
	end

	def oauth2_callback
		code = params[:code]
		if code.nil? || code.empty?
			raise "Missing code, can't authenticate user"
		end
		raise "TBD BRB 8-)"
	end

	def webhook
		# XXX move into .env file
		subscriber_verification_code = 'aa2b6337e95b970af5128e71b707d1dfa35382787e4317fed9dd33b36dd47135'
		subscriber_id = '1'
		code = params[:verify]
		unless code.nil?
			if code == subscriber_verification_code
				render body: nil, status: 204
			else
				render body: nil, status: 404
			end
		else
			raise "Nothing to do here"
		end

	end

	private

	def encode_secret(client_id, client_secret)
		Base64.strict_encode64(client_id + ?: + client_secret)
	end
end
