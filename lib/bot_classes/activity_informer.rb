require 'telegram/bot'
require 'bot_classes/general_actions'

class ActivityInformer
  attr_reader :user, :api, :state

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def inform
    delivered_plans = @user.plans.where(:delivered => 1)
    delivered_plans_names = delivered_plans.map(&:name)
    if delivered_plans.size > 0
      text = "Ciao #{@user.last_name}! Ti elenchero' tutti i piani che ti sono stati asegnati dal coach: \n"
      text += "-#{delivered_plans_names.join("\n-")}"
      buttons = %w[Attivita Feedback Tips]
      keyboard = GeneralActions.custom_keyboard buttons
      @user.set_user_state @state
      @api.call('sendMessage', chat_id: @user.telegram_id, text: text, reply_markup: keyboard)


      #create activities pdf
      controller = UsersController.new
      controller.instance_variable_set(:'@plans', delivered_plans)

      pdf = WickedPdf.new.pdf_from_string(
          controller.render_to_string('users/user_plans', layout: 'layouts/pdf.html'),
          dpi: '250',
                # orientation: 'Landscape',
                viewport: '1280x1024',
                footer: { right: '[page] of [topage]'}
      )
      save_path = Rails.root.join('pdfs',"#{@user.id}-plans.pdf")
      ap save_path
      File.open(save_path, 'wb') do |file|
        file << pdf
      end



      @api.call('sendDocument', chat_id: @user.telegram_id,
                document: Faraday::UploadIO.new("pdfs/#{@user.id}-plans.pdf", 'pdf'))


    else
      keyboard = GeneralActions.custom_keyboard %w[Attivita Feedback Tips]
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: 'Ancora non ci sono attivita\' definite per te.', reply_markup: keyboard)
    end
  end

  private
  def a_category(category)
    case category
      when 'diet'
        'DIETA'
      when 'health'
        'SALUTARE'
      when 'physical'
        'ATTIVITA\' FISICA'
      else
        'MEDICINA'
    end
  end

  def day(d)
    case d
      when 0
        'Lunedi'
      when 1
        'Martedi'
      when 2
        'Mercoledi'
      when 3
        'Giovedi'
      when 4
        'Venerdi'
      when 5
        'Sabato'
      else
        'Domenica'
    end
  end
end