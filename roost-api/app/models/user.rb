class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :jwt_authenticatable, 
         jwt_revocation_strategy: JwtDenylist

  has_many :bookings
  has_many :favorite_spaces
  has_many :favorited_spaces, through: :favorite_spaces, source: :space

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[admin staff user] }

  def admin?
    role == 'admin'
  end

  def staff?
    role == 'staff'
  end
end
