class FavoritesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @favorites = current_user.favorite_spaces.includes(:building)
  end
end