require 'telegram/bot'

class ImageSolver
  def init
  end

  def solve(telegram_id)
    token = Rails.application.secrets.bot_token
    api = ::Telegram::Bot::Api.new(token)
    user_profile = api.get_user_profile_photos(user_id: telegram_id)
    file_id = user_profile.dig('result', 'photos', 0, 0, 'file_id')
    file = api.get_file(file_id: file_id)
    file_path = file.dig('result', 'file_path')
    "https://api.telegram.org/file/bot#{token}/#{file_path}"
  end
end