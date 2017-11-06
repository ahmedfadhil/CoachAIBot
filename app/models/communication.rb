class Communication < ApplicationRecord
  enum status: { plan_finished: 0, profiling_done: 1, critical_user: 2, new_message: 3 }
end
