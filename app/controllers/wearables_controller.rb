require 'oauth2'
require 'base64'
require 'fitbit/client'
require 'bot/general_actions'

class WearablesController < ApplicationController
	before_action :authenticate_coach_user!, only: [:index, :show, :invite]
  respond_to :html
  layout 'cell_application'

	def index
		render layout: 'cell_application'
	end

	def show
		@user = User.find(params[:id])
	end

	def monthly_report
		@user = User.find(params[:id])
	end

	def weekly_chart
		@user = User.find(params[:id])
	end

	def monthly_chart
		@user = User.find(params[:id])
	end

	def edit
		@user = User.find(params[:id])
	end

	def invite
		@user = User.find(params[:id])
		# create a new identity token for the selected user
		@user.identity_token = SecureRandom.hex
		@user.save!
		@user.fitbit_invited!
		url = wearables_fitbit_connect_url(token: @user.identity_token)
		redirect_to wearables_url(@user)

		Thread.new {
			message1 = "Hai ricevuto un invito dal coach a collegare il tuo dispositivo indossabile"
			message2 = "Perfavore visita il seguente indirizzo per continuare: #{url}"
			ga = GeneralActions.new(@user, JSON.parse(@user.bot_command_data))
			ga.send_reply(message1)
			ga.send_reply(message2)
		}
	end

	def disable
		@user = User.find(params[:id])
		@user.fitbit_disabled!
		redirect_to edit_wearable_url(@user)
		Thread.new {
			message1 = "Gentile utente, l'integrazione con il tuo dispositivo indossabile è stata disabilitata"
			ga = GeneralActions.new(@user, JSON.parse(@user.bot_command_data))
			ga.send_reply(message1)
		}
	end

	def connect
		token = params[:token]
		user = User.where(identity_token: token).first
		unless user.nil?
			# give the user a cookie with his user id
			cookies[:user_id] = user.id

			# XXX move into .env file
			client_id = '228M5L'
			client_secret = 'ecec79fbdfec04ba40ba419186a3b25d'
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

		#Thread.new {
			user = User.find(user_id)
			user.fitbit_enabled!

			message1 = "Gentile utente, grazie per avere abilitato l'integrazione con il tuo dispositivo indossabile"
			ga = GeneralActions.new(user, JSON.parse(user.bot_command_data))
			ga.send_reply(message1)

			# XXX move into .env file and configuration
			client_id = '228M5L'
			client_secret = 'ecec79fbdfec04ba40ba419186a3b25d'
			redirect_uri = 'http://localhost:3000/users/auth/fitbit/callback'
			site = 'https://api.fitbit.com'

			client = OAuth2::Client.new(client_id, client_secret, site: site, authorize_url: '/oauth2/authorize', token_url: '/oauth2/token')
			secret = encode_secret(client_id, client_secret)
			access_token = client.auth_code.get_token(code, headers: {'Authorization' => "Basic #{secret}"}, redirect_uri: redirect_uri)

			user.access_token = access_token.to_hash
			user.save!

			#Fitbit::Client.pull_data("1m")
		#}
	end

	private

	def encode_secret(client_id, client_secret)
		Base64.strict_encode64(client_id + ?: + client_secret)
	end
end
