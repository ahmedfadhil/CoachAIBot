class Objective < ApplicationRecord
	has_many :users
	enum scheduler: { weekly: 0, monthly: 1 }
	enum activity: { steps: 0, distance: 1 }
end
