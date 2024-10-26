class SpaceUpdate < ApplicationRecord
  belongs_to :space

  validates :occupancy, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[available busy full closed] }
  validates :recorded_at, presence: true
end
