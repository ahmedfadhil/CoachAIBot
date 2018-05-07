
require 'telegram/bot'
require 'bot_v2/general'

class ActivityInformer
  attr_reader :user, :api, :state

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def send_activities
    delivered_plans = @user.plans.where(:delivered => 1)
    delivered_plans_names = delivered_plans.map(&:name)
    actuator = GeneralActions.new(@user,@state)
    actuator.send_chat_action 'typing'
    reply = "In breve hai da seguire i seguenti piani: \n\n"
    reply += "\t-#{delivered_plans_names.join("\n\t-")}"
    actuator.send_reply_with_keyboard(reply,GeneralActions.custom_keyboard(['Scarica Dettagli', 'Torna al Menu']))
  end

  def inform_no_activities
    actuator = GeneralActions.new(@user,@state)
    actuator.send_chat_action 'typing'
    if @user.profiled?
      reply = 'Momentaneamente non ci sono attivita\' da fare. Ricontrolla piu\' tardi.'
    else
      reply = 'Momentaneamente non ci sono attivita\' da fare. Completa prima i questionari presenti nella sezione QUESTIONARI.'
    end
    actuator.send_reply_with_keyboard(reply, GeneralActions.menu_keyboard)
  end

  def send_details
    delivered_plans = @user.plans.where(:delivered => 1)
    send_plans_details(delivered_plans)
  end

  def activities_present?
    delivered_plans = @user.plans.where(:delivered => 1)
    delivered_plans.size > 0
  end

  def send_menu
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply_with_keyboard("Se hai bisogno di ulteriori dettagli torna nella sezione attivita'", GeneralActions.menu_keyboard)
  end

  def send_plans_details(delivered_plans)
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply "#{@user.first_name} ti sto inviando il documento con tutti i dettagli relativi alle tua attività..."
    actuator.send_chat_action 'upload_document'

    controller = UsersController.new
    controller.instance_variable_set(:'@plans', delivered_plans)
    doc_name = "Piano di #{user.first_name} #{user.last_name}.pdf"

    pdf = WickedPdf.new.pdf_from_string(
        controller.render_to_string('users/user_plans', layout: 'layouts/pdfs.html'),
        dpi: '250',
        # orientation: 'Landscape',
        viewport: '1280x1024',
        footer: { right: '[page] of [topage]'}
    )
    save_path = Rails.root.join('pdfs',doc_name)
    File.open(save_path, 'wb') do |file|
      file << pdf
    end

    file_path = "pdfs/#{doc_name}"
    actuator.send_doc file_path
    actuator.send_reply_with_keyboard 'Leggilo con attenzione!', GeneralActions.menu_keyboard
    File.delete(file_path) if File.exist?(file_path)
  end

end