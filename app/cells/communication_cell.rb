class CommunicationCell < Cell::ViewModel
  def show
    render
  end

  def communication
    model
  end

  def compute_class
    'communication_not_read' if communication.read_at.nil?
  end

  def time
    communication.created_at.strftime('%d.%m.%Y - %H:%M')
  end

end
