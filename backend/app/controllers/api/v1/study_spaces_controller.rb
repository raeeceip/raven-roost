module Api
  module V1
    class StudySpacesController < ApplicationController
      def index
        study_spaces = StudySpace.includes(:building).all
        render json: study_spaces, include: :building
      end
      
      def show
        study_space = StudySpace.includes(:building).find(params[:id])
        render json: study_space, include: :building
      end
    end
  end
en