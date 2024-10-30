module Api
  module V1
    class BuildingsController < ApplicationController
      def index
        buildings = Building.includes(:study_spaces).all
        render json: buildings, include: :study_spaces
      end
      
      def show
        building = Building.includes(:study_spaces).find(params[:id])
        render json: building, include: :study_spaces
      end
    end
  end
end