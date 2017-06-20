require 'BotManager_Base'

module BotManager

  class New < Base
    def should_start?
      text =~ /\A\/start/
    end

    def start
      #first msg on start
      send_message('Ciao io sono CoachAI dove AI sta per Artificial Inteligence.')
      user.reset_user_state          #resetting previous state

      #creating the initial state
      s = {}
      content = {}
      state = {}

      s["state"] = "new"
      content["health"] = false
      content["physical"] = false
      content["coping"] = false
      content["mental"] = false

      state["state"] = s
      state["content"] = content

      user.set_user_state(state)     #setting

      #send empty msg to Chatscript to inform that a new session is initialized
    end

    def should_start
      send_message('Ciao! Io sono un robot che fa da personal trainer. Se vuoi iniziare a chattare con me '+
                        'digita /start')
    end

  end

end