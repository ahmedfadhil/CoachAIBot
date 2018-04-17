class CoachUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,:validatable,:registerable
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "pp.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  #validates :avatar, attachment_presence: true
  #validates_with AttachmentPresenceValidator, attributes: :avatar
  # validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 1.megabytes



  validates_uniqueness_of :email, message: 'Email in uso. Scegli altra email.'
  validates :first_name, presence: { message: 'Nome obbligatorio.' }, length: { maximum: 50, message: 'Nome troppo lungo, massimo 50 caratteri.' }
  validates :last_name, presence: { message: 'Cognome obbligatorio.' }, length: { maximum: 50, message: 'Cognome troppo lungo massimo 50 caratteri' }
  # validates :password, presence: { message: 'password obbligatoria.' }, length: { minimum: 8, message: 'Password troppo lunga, massimo 8 caratteri' }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: 'Email obbligatoria.' }, length: { maximum: 255, message: 'Email troppo lunga, massimo 255 caratteri' }, format: { with: VALID_EMAIL_REGEX, message: 'Email non valida, scegliere un email della forma esempio@myemail.org' }
  has_many :users
  has_many :chats
  has_many :events
  has_many :communications, dependent: :destroy




end
