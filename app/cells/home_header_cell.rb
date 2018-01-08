class HomeHeaderCell < Cell::ViewModel
  def show
    render
  end

  def coach_user_signed_in?
    model
  end

end
