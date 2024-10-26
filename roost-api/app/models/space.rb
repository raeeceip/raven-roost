class Space < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :space_updates, dependent: :destroy
  has_many :favorite_spaces, dependent: :destroy
  has_many :space_amenities, dependent: :destroy
  has_many :users_who_favorited, through: :favorite_spaces, source: :user

  validates :name, presence: true
  validates :building, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validates :current_occupancy, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[available busy full closed] }

  def update_occupancy!(count)
    self.current_occupancy = count
    self.status = calculate_status(count)
    self.last_updated = Time.current
    save!
    
    broadcast_update
    create_space_update(count)
  end

  private

  def calculate_status(count)
    case
    when count >= capacity * 0.9 then 'full'
    when count >= capacity * 0.7 then 'busy'
    else 'available'
    end
  end

  def broadcast_update
    ActionCable.server.broadcast 'spaces_channel', {
      id: id,
      current_occupancy: current_occupancy,
      status: status,
      last_updated: last_updated
    }
  end

  def create_space_update(count)
    space_updates.create!(
      occupancy: count,
      status: status,
      source: 'system',
      recorded_at: Time.current
    )
  end
end
