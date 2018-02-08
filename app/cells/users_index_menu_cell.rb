class UsersIndexMenuCell < Cell::ViewModel
  REGISTERED = 'REGISTERED'
  ARCHIVED = 'ARCHIVED'

  def show
    render
  end

  def coach
    model
  end

  def registered
    User.where('coach_user_id = ? AND state = ?', coach.id, REGISTERED).count
  end

  def archived
    User.where('coach_user_id = ? AND state = ?', coach.id, ARCHIVED).count
  end

end
