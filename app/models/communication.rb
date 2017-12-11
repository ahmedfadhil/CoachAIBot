class Communication < ApplicationRecord
  belongs_to :coach_user
  belongs_to :user

  enum status: { plan_finished: 0, profiling_done: 1, critical_user: 2, new_message: 3 }
end
