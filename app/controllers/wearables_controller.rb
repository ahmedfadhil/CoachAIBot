require 'oauth2'
require 'base64'

class WearablesController < ApplicationController
	before_action :authenticate_coach_user!, only: [:index, :show, :invite]
  respond_to :html
  layout 'profile'

	def index
		render layout: 'cell_application'
	end

	def show
		@user = User.find(params[:id])
	end

	def invite
		@user = User.find(params[:id])

		# create a new identity token for the selected user
		@user.identity_token = SecureRandom.hex
		@user.save!

		url = wearables_fitbit_connect_url(token: @user.identity_token)
		message1 = "Hai ricevuto un invito dal coach a collegare il tuo dispositivo indossabile"
		message2 = "Perfavore visita il seguente indirizzo per continuare: #{url}"

		ga = GeneralActions.new(@user, JSON.parse(@user.bot_command_data))
		ga.send_reply(message1)
		ga.send_reply(message2)
		redirect_to wearables_show_url(@user)
	end

	def connect
		token = params[:token]
		user = User.where(identity_token: token).first
		unless user.nil?
			# give the user a cookie with his user id
			cookies[:user_id] = user.id

			# use own id or load from .env file
			client_id = 'xxxxx'
			client_secret = 'xxxxx'
			redirect_uri = 'http://localhost:3000/users/auth/fitbit/callback'

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
		user_id = cookies[:user_id]
		if user_id.nil?
			raise "Missing auth cookie, can't authenticate user"
		end
		user = User.find(user_id)

		# use own id or load from .env file
		client_id = 'xxxxx'
		client_secret = 'xxxxx'
		redirect_uri = 'http://localhost:3000/users/auth/fitbit/callback'
		site = 'https://api.fitbit.com'

		client = OAuth2::Client.new(client_id, client_secret, site: site, authorize_url: '/oauth2/authorize', token_url: '/oauth2/token')
		secret = encode_secret(client_id, client_secret)
		access_token = client.auth_code.get_token(code, headers: {'Authorization' => "Basic #{secret}"}, redirect_uri: redirect_uri)

		user.access_token = access_token.to_hash
		user.save!
	end

	private

	def encode_secret(client_id, client_secret)
		Base64.strict_encode64(client_id + ?: + client_secret)
	end
end
