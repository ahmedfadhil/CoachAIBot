class Plan < ApplicationRecord
  belongs_to :user, optional: true
  has_many :plannings, dependent: :destroy
  has_many :activities, :through => :plannings

  validates :from_day, presence: { message: 'Inserisci DATA INIZIO piano.' }
  validates :to_day, presence: { message: 'Inserisci DATA FINE piano.' }
  validates :name, presence: { message: 'Il piano deve avere un nome' }, length: { maximum: 50, message: "Il nome del piano non puo' essere piu' lungo di 50 caratteri" }

  validate :date_cannot_be_in_the_past, on: :create

  def  date_cannot_be_in_the_past
    if self.from_day < Date.today || self.to_day <= self.from_day
      errors.add(:date, "Il piano non puo' iniziare nel passato o finire prima che inizi. Ricontrolla le date!")
    end
  end
end

