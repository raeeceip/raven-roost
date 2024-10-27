module Searchable
  extend ActiveSupport::Concern

  included do
    searchkick word_start: [:name, :building],
              suggest: [:name],
              searchable: [:name, :building, :status, :amenities],
              callbacks: :async

    def search_data
      {
        name: name,
        building: building,
        status: status,
        amenities: amenities,
        current_occupancy: current_occupancy,
        capacity: capacity,
        occupancy_rate: (current_occupancy.to_f / capacity * 100).round(2),
        created_at: created_at
      }
    end
  end
end
