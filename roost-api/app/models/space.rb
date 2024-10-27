class Space < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

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

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false do
      indexes :name, type: :text, analyzer: 'english'
      indexes :building, type: :text, analyzer: 'english'
      indexes :capacity, type: :integer
      indexes :status, type: :keyword
      indexes :current_occupancy, type: :integer
      indexes :last_updated, type: :date
    end
  end

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
    when count == 0
      'available'
    when count < capacity / 2
      'busy'
    when count < capacity
      'full'
    else
      'closed'
    end
  end

  def broadcast_update
    # Implement broadcasting logic here
  end

  def create_space_update(count)
    space_updates.create!(occupancy: count, updated_at: Time.current)
  end
  def self.create_index!
    __elasticsearch__.create_index! force: true
    __elasticsearch__.refresh_index!
  end
end