class Response < ApplicationRecord
  belongs_to :patient
  belongs_to :question

  alias_method :user, :patient
  alias_method :user=, :patient=
end
