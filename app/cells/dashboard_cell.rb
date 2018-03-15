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
    User.left_outer_joins(:plans).where("plans.user_id is null")
    # User.all.count - User.joins(:plans).where(coach_user: coach).uniq.count
  end
  
  def all_users
    User.all.count
  end
  
  def users_with_no_plan_count
    User.all.count - User.joins(:plans).where(coach_user: coach).uniq.count
  end
  
  def users_with_plans
    User.joins(:plans).where(coach_user: coach).uniq
  end
  
  def users_with_plans_count
    User.joins(:plans).where(coach_user: coach).uniq.count
  end
  
  def users_count
    User.where(:coach_user_id => model.id).count
  end
  
  def plans_count(user)
    Plan.joins(:user).where(:users => {:id => user.id}).count
  end
  
  def global_plans_count
    Plan.joins(:user).where(:users => {:coach_user_id => model.id}).count
  end
  
  def global_activities_count
    Activity.all.count
  end
  
  def activities_count(user)
    Activity.joins(:plans).where(:plans => {:user_id => user.id}).count
  end
  
  def user_id_link(user)
    link_to "#{user.id}", user
  end
  
  
  def user_name_link(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
  
  def user_profile_image(user)
    if user.telegram_id.nil?
      default_image
    else
      begin
        solver = ImageSolver.new
        solver.solve(user.telegram_id)
      rescue Exception
        default_image
      end
    end
  end
  
  def default_image
    'https://i.imgur.com/hur32sb.png'
  end


end