class CommunicationsCell < Cell::ViewModel
  def show
    render
  end

  def coach
    model
  end

  def communications
    coach.communications
  end

end
