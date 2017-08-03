class Feature < ApplicationRecord
  belongs_to :patient

  alias_method :user, :patient
  alias_method :user=, :patient=
end
