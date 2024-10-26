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
