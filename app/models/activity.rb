class Activity < ApplicationRecord
  validates_uniqueness_of :name, message: "Attivita' con lo stesso nome gia' presente nel sistema"
  validates :desc, presence: { message: 'Descrizione obbligatoria.' }
  validates :category, presence: { message: 'Categoria obbligatoria' }
  validates :a_type, presence: { message: 'Tipologia obbligatoria' }
  validates :n_times, presence: { message: 'Numero di volte obbligatoria' }

  belongs_to :coach_user, optional: false
  has_many :plannings, dependent: :destroy
  has_many :plans, :through => :plannings
  has_many :users, :through => :plans
end


# user.where(first_name"name").destroy rail s
#
# User.with_deleted.where(:activities.name=>"")