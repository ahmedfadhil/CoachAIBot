class ProfileHeaderCell < Cell::ViewModel
  def show
    render
  end

  def coach
    model
  end

  def title
    options[:title]
  end
end
