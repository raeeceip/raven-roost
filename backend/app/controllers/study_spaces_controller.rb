# app/controllers/study_spaces_controller.rb
class StudySpacesController < ApplicationController
  before_action :set_study_space, only: [:show, :toggle_favorite]
  before_action :authenticate_user!, only: [:toggle_favorite]
  
  def index
    @study_spaces = StudySpace.all
    @buildings = Building.all
  end
  
  def show
    @building = @study_space.building
  end
  
  def search
    @study_spaces = StudySpace.all
    
    if params[:query].present?
      @study_spaces = @study_spaces.where("name ILIKE ? OR description ILIKE ?", 
                                        "%#{params[:query]}%", 
                                        "%#{params[:query]}%")
    end
    
    if params[:building_id].present?
      @study_spaces = @study_spaces.by_building(params[:building_id])
    end
    
    if params[:min_capacity].present?
      @study_spaces = @study_spaces.by_capacity(params[:min_capacity])
    end
    
    if params[:status].present?
      @study_spaces = @study_spaces.where(status: params[:status])
    end
    
    render json: @study_spaces.includes(:building)
  end
  
  def toggle_favorite
    favorite = current_user.favorites.find_by(study_space: @study_space)
    
    if favorite
      favorite.destroy
      render json: { favorited: false }
    else
      current_user.favorites.create(study_space: @study_space)
      render json: { favorited: true }
    end
  end
  
  private
  
  def set_study_space
    @study_space = StudySpace.find(params[:id])
  end