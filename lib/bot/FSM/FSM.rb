class FSM
  attr_accessor :user, :bot_command_data

  state_machine :state, initial: :idle do

    after_transition idle: :messages, do: :show_messages

    event :get_messages do
      transition idle: :messages
    end

    event :cancel do
      transition messages: :idle
    end

    event :respond do
      transition messages: :idle
    end
  end

  def show_messages
    ap 'messages'
  end

  def update_model!(model)
    model['fsm_state'] = state
  end

  def self.from_model(user, model)
    obj = new(user)
    obj.state = model['fsm_state']
    return obj
  end

  def initialize(user, bot_command_data)
    @user = user
    @bot_command_data = @bot_command_data
    super() # NOTE: This *must* be called, otherwise states won't get initialized
  end

end