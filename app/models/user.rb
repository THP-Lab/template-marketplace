class User < ApplicationRecord
  NAME_REGEX = /\A[a-zA-Z]+\z/
  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/
  PROFILE_FIELDS = %i[first_name last_name address zipcode city country phone].freeze


  # Include default devise modules..
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  after_create :create_cart
  has_many :orders, dependent: :nullify
  has_many :events

  validates :first_name, :last_name, format: { with: NAME_REGEX, message: "n'accepte que des lettres" }, allow_blank: true
  validates :email, format: { with: EMAIL_REGEX }
  validates :cgu_accepted, acceptance: { accept: true }

  after_commit :send_welcome_email, on: :create

  def missing_profile_fields
    PROFILE_FIELDS.select { |field| send(field).blank? }
  end

  def profile_complete?
    missing_profile_fields.empty?
  end

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
