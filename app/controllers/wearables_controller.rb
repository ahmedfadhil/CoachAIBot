require 'oauth2'
require 'base64'

class WearablesController < ApplicationController
	def connect
		token = params[:token]
		user = User.where(identity_token: token).first
		unless user.nil?
			# XXX move into .env file
			client_id = '228M5L'
			client_secret = 'ecec79fbdfec04ba40ba419186a3b25d'
			redirect_uri = 'http://localhost:3000/users/auth/fitbit/callback'
			# XXX

			# make sure you point to /oauth2/authorize otherwise it won't work!
			client = OAuth2::Client.new(client_id, client_secret, site: 'https://www.fitbit.com', authorize_url: '/oauth2/authorize')
			url = client.auth_code.authorize_url(redirect_uri: redirect_uri) + "&scope=activity%20sleep"
			redirect_to url
		else
			raise "Invalid identity_token"
		end
	end

	private

	def encode_secret(client_id, client_secret)
		Base64.strict_encode64(client_id + ?: + client_secret)
	end
end
