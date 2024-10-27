# app/controllers/api/v1/spaces_controller.rb
module Api
  module V1
    class SpacesController < BaseController
      before_action :set_space, only: [:show, :update, :destroy, :update_occupancy]

      def index
        @spaces = Space.includes(:space_amenities)
        @spaces = @spaces.where(building: params[:building]) if params[:building].present?
        @spaces = @spaces.where(status: params[:status]) if params[:status].present?

        render json: @spaces, include: [:space_amenities]
      end

      def show
        render json: @space, include: [:space_amenities]
      end

      def create
        authorize Space
        @space = Space.new(space_params)

        if @space.save
          render json: @space, status: :created
        else
          render json: { errors: @space.errors }, status: :unprocessable_entity
        end
      end

      def update
        authorize @space

        if @space.update(space_params)
          render json: @space
        else
          render json: { errors: @space.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @space
        @space.destroy
        head :no_content
      end

      def update_occupancy
        authorize @space
        
        if @space.update_occupancy!(params[:occupancy])
          render json: @space
        else
          render json: { errors: @space.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_space
        @space = Space.find(params[:id])
      end

      def space_params
        params.require(:space).permit(:name, :building, :capacity, :status, amenities: {})
      end
    end
  end
end