class SearchController < ApplicationController
  def search
    if params[:query].present?
      @users = User.search(params[:query]).records
    else
      @users = User.all
    end
    render json: @users
  end
end
