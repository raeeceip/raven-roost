# app/serializers/space_serializer.rb
class SpaceSerializer < ActiveModel::Serializer
    attributes :id, :name, :building, :capacity, :status, :current_occupancy, :last_updated
  
    has_many :space_amenities
  end