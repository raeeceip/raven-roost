# app/models/favorite.rb
class Favorite < ApplicationRecord
    belongs_to :user
    belongs_to :study_space
    
    validates :user_id, uniqueness: { scope: :study_space_id }
  end