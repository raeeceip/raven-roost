class SpaceAmenity < ApplicationRecord
  belongs_to :space

  validates :name, presence: true
  validates :name, uniqueness: { scope: :space_id }
  validates :available, inclusion: { in: [true, false] }
end
