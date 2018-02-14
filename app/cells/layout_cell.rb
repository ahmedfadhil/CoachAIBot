class LayoutCell < Cell::ViewModel
	include Devise::Controllers::Helpers

	def show(&block)
		render(&block)
	end

	private

	def title
		model.capitalize
	end

	def navigation_link(path, icon, name)
		link_to path, class: 'mdl-navigation__link' do
			content_tag(:i, icon, class: 'mdl-color-text--blue-grey-400 material-icons') + name
		end
	end
end
