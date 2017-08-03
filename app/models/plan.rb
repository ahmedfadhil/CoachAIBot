class Plan < ApplicationRecord
  belongs_to :patient, optional: true
  has_many :plannings, dependent: :destroy

  alias_method :user, :patient
  alias_method :user=, :patient=
end
