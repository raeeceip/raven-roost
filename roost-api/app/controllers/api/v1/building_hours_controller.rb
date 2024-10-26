module Api
  module V1
    class BuildingHoursController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_building_hours, only: [:show, :update, :destroy]

      def index
        @hours = BuildingHours.all
        @hours = @hours.where(building: params[:building]) if params[:building].present?
        
        render json: BuildingHoursSerializer.new(@hours).serializable_hash
      end

      def create
        authorize BuildingHours
        @hours = BuildingHours.new(building_hours_params)

        if @hours.save
          render json: BuildingHoursSerializer.new(@hours).serializable_hash, status: :created
        else
          render json: { errors: @hours.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_building_hours
        @hours = BuildingHours.find(params[:id])
      end

      def building_hours_params
        params.require(:building_hours).permit(:building, :day_of_week, :opens_at, :closes_at, :is_closed)
      end
    end
  end
end
