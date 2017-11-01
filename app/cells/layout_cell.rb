class LayoutCell < Cell::ViewModel
	include Devise::Controllers::Helpers

	def show(&block)
		render(&block)
	end

	private

	def section
		model[:section]
	end

	def title
		model[:title]
	end

	def navigation_link(name, path)
		content_tag :li, class: "nav-item" do
			if section == name
				link_to name.capitalize, path, class: "nav-link active"
			else
				link_to name.capitalize, path, class: "nav-link"
			end
		end
	end
end
