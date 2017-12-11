class DashboardCell < Cell::ViewModel
  def show
    render
  end

  def headers
    render
  end

  def coach
    model
  end

  def greens
    User.joins(:plans).where(:plans => {:delivered => 1}, :coach_user_id => model.id, :cluster => 0).uniq
  end

  def yellows
    User.joins(:plans).where(:plans => {:delivered => 1}, :coach_user_id => model.id, :cluster => 1).uniq
  end

  def reds
    User.joins(:plans).where(:plans => {:delivered => 1}, :coach_user_id => model.id, :cluster => 2).uniq
  end

  def users_with_no_plan
    i = 0
    User.where(:coach_user_id => model.id, :state => 'REGISTERED').each do |u|
      if u.plans.nil?
        i = i + 1
      end
    end
    i
  end

  def users_with_plans
    i = 0
    User.where(:coach_user_id => model.id, :state => 'REGISTERED').each do |u|
      unless u.plans.nil?
        i = i + 1
      end
    end
    i
  end

  def users_count
    User.where(:coach_user_id => model.id).count
  end

  def plans_count
    Plan.joins(:user).where(:users => {:coach_user_id => model.id}).count
  end

  def activities_count
    Activity.all.count
  end

  def user_id_link(user)
    link_to "#{user.id}", user
  end

  def user_name_link(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end

end