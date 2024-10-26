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
