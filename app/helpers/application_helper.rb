module ApplicationHelper
  def resource_name
    :coach_user
  end

  def resource
    @resource ||= CoachUser.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:coach_user]
  end
end
