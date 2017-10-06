require 'telegram/bot'

class DocumentSender
  attr_reader :user, :api, :state

  def initialize(user)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
  end

  def send_plans_details(user)
    file_name = "#{@user.id}-#{@user.first_name}-plans.pdf"
    controller = UsersController.new
    controller.instance_variable_set(:'@plans', delivered_plans)

    pdf = WickedPdf.new.pdf_from_string(
        controller.render_to_string('users/user_plans', layout: 'layouts/pdf.html'),
        dpi: '250',
        # orientation: 'Landscape',
        viewport: '1280x1024',
        footer: { right: '[page] of [topage]'}
    )
    save_path = Rails.root.join('pdfs',file_name)
    ap save_path
    File.open(save_path, 'wb') do |file|
      file << pdf
    end

    @api.call()
    @api.call('sendDocument', chat_id: @user.telegram_id,
              document: Faraday::UploadIO.new(file_name, 'pdf'))


  end

  private

end