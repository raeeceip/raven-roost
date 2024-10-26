#!/bin/bash

# Exit on error
set -e

echo "🚀 Generating model files..."

# Create app/models directory if it doesn't exist
mkdir -p app/models

# Generate User model
cat > app/models/user.rb << 'EOF'
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
EOF

# Generate Space model
cat > app/models/space.rb << 'EOF'
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
EOF

# Generate Booking model
cat > app/models/booking.rb << 'EOF'
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :space

  validates :start_time, :end_time, presence: true
  validates :status, inclusion: { in: %w[pending confirmed cancelled completed] }
  validate :end_time_after_start_time
  validate :no_overlap
  validate :within_building_hours
  validate :space_available

  scope :active, -> { where(status: %w[pending confirmed]) }
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :current, -> { where('start_time <= ? AND end_time >= ?', Time.current, Time.current) }

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlap
    overlapping = space.bookings
                      .where.not(id: id)
                      .where(status: %w[pending confirmed])
                      .where('start_time < ? AND end_time > ?', end_time, start_time)
    
    if overlapping.exists?
      errors.add(:base, "Time slot already booked")
    end
  end

  def within_building_hours
    building_hours = BuildingHours.find_by(
      building: space.building,
      day_of_week: start_time.wday
    )

    return if building_hours.nil?

    unless building_hours.open_at?(start_time) && building_hours.open_at?(end_time)
      errors.add(:base, "Booking must be within building hours")
    end
  end

  def space_available
    return if space.nil?

    if space.status == 'closed'
      errors.add(:space, "is currently closed")
    end
  end
end
EOF

# Generate SpaceUpdate model
cat > app/models/space_update.rb << 'EOF'
class SpaceUpdate < ApplicationRecord
  belongs_to :space

  validates :occupancy, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[available busy full closed] }
  validates :recorded_at, presence: true
end
EOF

# Generate FavoriteSpace model
cat > app/models/favorite_space.rb << 'EOF'
class FavoriteSpace < ApplicationRecord
  belongs_to :user
  belongs_to :space

  validates :user_id, uniqueness: { scope: :space_id }
end
EOF

# Generate BuildingHours model
cat > app/models/building_hours.rb << 'EOF'
class BuildingHours < ApplicationRecord
  validates :building, presence: true
  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :opens_at, :closes_at, presence: true
  validates :building, uniqueness: { scope: :day_of_week }

  def open_at?(time)
    return false if is_closed
    
    time_of_day = time.strftime("%H:%M")
    time_of_day >= opens_at.strftime("%H:%M") && 
      time_of_day <= closes_at.strftime("%H:%M")
  end
end
EOF

# Generate SpaceAmenity model
cat > app/models/space_amenity.rb << 'EOF'
class SpaceAmenity < ApplicationRecord
  belongs_to :space

  validates :name, presence: true
  validates :name, uniqueness: { scope: :space_id }
  validates :available, inclusion: { in: [true, false] }
end
EOF

echo "✅ Model files generated successfully!"