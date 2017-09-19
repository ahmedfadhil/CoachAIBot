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

    pdf = Prawn::Document.new(:margin => 50)
    pdf.text "Panoramica <color rgb='ff0000'>Piani</color> e <color rgb='0000ff'>Attivita'</color>",
       :inline_format => true,
       :align => :center,
       :size => 16
    pdf.move_down 20

    pdf.font_size 10
    pdf.text "Utente: #{@user.first_name} #{@user.last_name}",
             :align => :right
    pdf.text "Coach: #{@user.coach_user.first_name} #{@user.coach_user.last_name}",
             :align => :right
    pdf.text "Data: #{Date.today.strftime('%d/%m/%y')}",
             :align => :right



    text = "Ciao #{@user.last_name}! Ti elenchero' tutti i piani e le loro attivita' che hai da fare: \n\n"
    delivered_plans = @user.plans.where(:delivered => 1)
    if delivered_plans.size > 0
      i = 0
      delivered_plans.find_each do |plan|
        j = 1
        text = text + "\t #{i+1}. Piano: '#{plan.name}' \n\t\tCon le seguenti attivita':\n"

        pdf.move_down 10
        pdf.font_size 13
        pdf.text "#{i+1}. Piano <color rgb='ff0000'>#{plan.name}</color>",
                 :inline_format => true

        pdf.text "Per il <u>Periodo</u>: dal <b>#{plan.from_day.strftime('%d/%m/%y')}</b> al <b>#{plan.to_day.strftime('%d/%m/%y')}</b>",
                 :indent_paragraphs => 30, :inline_format => true

        pdf.move_down 5
        pdf.text 'Con le seguenti <b>ATTIVITA\'</b>:',
                 :indent_paragraphs => 30, :inline_format => true

        plan.plannings.find_each do |planning|
          pdf.move_down 5

          activity = planning.activity
          text = text + "\t\t\t #{j}. #{activity.name}\n"

          pdf.text "#{j}. <color rgb='0000ff'>#{activity.name}</color>",
                   :indent_paragraphs => 30, :inline_format => true

          pdf.text "-Categoria: <b>#{a_category(activity.category)}</b>",
                   :indent_paragraphs => 60, :inline_format => true

          case activity.a_type
            when 'daily'
              pdf.text '-Tipologia: <b>GIORNALIERA</b>',
                       :indent_paragraphs => 60, :inline_format => true

              pdf.text "-Frequenza: <b>#{activity.n_times}/giorno</b>",
                       :indent_paragraphs => 60, :inline_format => true

              unless planning.schedules.empty?
                pdf.text "-Programmazione:",
                         :indent_paragraphs => 60

                planning.schedules.find_each do |schedule|
                  pdf.text "<b>#{day(schedule.day)}</b> Ora <b>#{schedule.time.strftime('%H:%M')}</b>",
                           :indent_paragraphs => 90, :inline_format => true
                end
              end
            when 'weekly'
              pdf.text '-Tipologia: <b>SETTIMANALE</b>',
                       :indent_paragraphs => 60, :inline_format => true

              pdf.text "-Frequenza: <b>#{activity.n_times}/settimana</b>",
                       :indent_paragraphs => 60, :inline_format => true
              unless planning.schedules.empty?
                pdf.text "-Programmazione:",
                         :indent_paragraphs => 60

                planning.schedules.find_each do |schedule|
                  pdf.text "Giorno <b>#{schedule.date.strftime('%d/%m/%y')}</b> Ora <b>#{schedule.time.strftime('%H:%M')}</b>",
                           :indent_paragraphs => 90, :inline_format => true
                end
              end

            else # monthly
              pdf.text '-Tipologia: <b>MENSILE</b>',
                       :indent_paragraphs => 60, :inline_format => true

              pdf.text "-Frequenza: <b>#{activity.n_times}/mese</b>",
                       :indent_paragraphs => 60, :inline_format => true

              unless planning.schedules.empty?
                pdf.text "-Programmazione:",
                         :indent_paragraphs => 60

                ap planning.schedules

                planning.schedules.find_each do |schedule|
                  pdf.text "Giorno <b>#{schedule.date.strftime('%d/%m/%y')}</b>",
                           :indent_paragraphs => 90, :inline_format => true
                end
              end


          end

          pdf.text "-Ulteriori Dettagli: <b>#{activity.desc}</b>",
                   :indent_paragraphs => 60, :inline_format => true
          # pdf.text_box "Another text box with no :width option passed, so it will " +
          #             "flow to a new line whenever it reaches the right margin. ",
          #         :at => pdf.cursor


          j = j + 1
        end
        i = i + 1
      end
      text = text + "\n"

      pdf.render_file 'example.pdf'

      if i == delivered_plans.size
        buttons = %w[Attivita Feedback Tips]
        keyboard = GeneralActions.custom_keyboard buttons
        @user.set_user_state @state
        @api.call('sendMessage', chat_id: @user.telegram_id, text: text, reply_markup: keyboard)
      else
        @api.call('sendMessage', chat_id: @user.telegram_id, text: text)
      end



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