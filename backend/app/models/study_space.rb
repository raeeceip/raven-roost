# app/models/study_space.rb
class StudySpace < ApplicationRecord
    belongs_to :building
    has_many :favorites, dependent: :destroy
    has_many :favorited_by, through: :favorites, source: :user
    
    validates :name, presence: true
    validates :capacity, presence: true, numericality: { greater_than: 0 }
    validates :status, inclusion: { in: ['available', 'limited', 'full', 'closed'] }
    validates :noise_level, inclusion: { in: 0..3 } # 0: silent, 1: quiet, 2: moderate, 3: loud
    
    scope :available, -> { where(status: 'available') }
    scope :by_building, ->(building_id) { where(building_id: building_id) }
    scope :by_capacity, ->(min_capacity) { where('capacity >= ?', min_capacity) }
  end
  