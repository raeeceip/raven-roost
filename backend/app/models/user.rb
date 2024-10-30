class User < ApplicationRecord
    has_many :favorites, dependent: :destroy
    has_many :favorite_spaces, through: :favorites, source: :study_space
    
    validates :email, presence: true, uniqueness: true
    validates :name, presence: true
    validates :role, inclusion: { in: ['student', 'staff', 'admin'] }
    
    def self.from_google_auth(auth)
      where(google_uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.name = auth.info.name
        user.avatar_url = auth.info.image
      end
    end
  end
  