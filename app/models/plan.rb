class Plan < ApplicationRecord
  belongs_to :user
  has_many :plannings, dependent: :destroy
  has_many :activities, :through => :plannings

  validates :from_day, presence: { message: 'Inserisci DATA INIZIO piano.' }
  validates :to_day, presence: { message: 'Inserisci DATA FINE piano.' }
  validates :name, presence: { message: 'Il piano deve avere un nome' }, length: { maximum: 50, message: "Il nome del piano non puo' essere piu' lungo di 50 caratteri" }
  validates_uniqueness_of :name, message: "Tutti i piani devono avere nomi diversi. Scegli un'atro nome!"
  validate :date_cannot_be_in_the_past, on: :create
  validate :check_delivering_conditions

  def  date_cannot_be_in_the_past
    if self.from_day < Date.today || self.to_day <= self.from_day
      errors.add(:date, "Il piano non puo' iniziare nel passato o finire prima che inizi. Ricontrolla le date!")
    end
  end

  def check_delivering_conditions
    unless self.user.profiled?
      errors.add(:user, "Il paziente non ha completato la fase di profilazione, riceverai una notifica quando questo accadra'")
    end
    if self.user.archived?
      errors.add(:user, "Il paziente e' archiviato, quindi non puo' ricevere attivita' da fare")
    end
  end

  def ita_duration
    "Dal #{self.from_day.strftime('%-m/%-d/%Y')} al #{self.to_day.strftime('%-m/%-d/%Y')} - #{(self.to_day-self.from_day).to_i} Giorni"
  end

  def has_period_exceeded?
    self.to_day < Date.today
  end

  def has_missing_feedback?
    Notification.joins(planning: :plan).where('notifications.done=?  AND plans.id=?', 0, self.id).count > 0
  end

  def has_plannings?
    !(self.plannings.count == 0)
  end

  def is_finished?
    Notification.joins(planning: :plan).where('plans.id = ? AND notifications.done = ?', self.id, 0).empty?
  end
end

