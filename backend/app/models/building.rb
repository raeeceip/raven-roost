class Building < ApplicationRecord
    has_many :study_spaces, dependent: :destroy
    
    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :latitude, :longitude, presence: true,
              numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  end
  