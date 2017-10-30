class Chat < ApplicationRecord
  belongs_to :coach_user
  belongs_to :user

  validates :text, presence: { message: 'Inserisci del testo nel messaggio.' }
end
