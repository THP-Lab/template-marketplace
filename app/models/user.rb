class User < ApplicationRecord
  NAME_REGEX = /\A[a-zA-Z]+\z/
  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :cart, dependent: :destroy
  after_create :create_cart
  has_many :orders
  has_many :events

  validates :first_name, :last_name,
            presence: true,
            format: { with: NAME_REGEX, message: "n'accepte que des lettres" }
  validates :email, format: { with: EMAIL_REGEX }
  validates :cgu_accepted, acceptance: { accept: true }

  after_commit :send_welcome_email, on: :create

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
