module Api
  module V1
    class SpacesController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_space, only: [:show, :update, :destroy, :update_occupancy]

      def index
        @spaces = Space.includes(:space_amenities)
        @spaces = @spaces.where(building: params[:building]) if params[:building].present?
        @spaces = @spaces.where(status: params[:status]) if params[:status].present?

        render json: SpaceSerializer.new(@spaces, include: [:space_amenities]).serializable_hash
      end

      def show
        render json: SpaceSerializer.new(@space, include: [:space_amenities]).serializable_hash
      end

      def create
        authorize Space
        @space = Space.new(space_params)

        if @space.save
          render json: SpaceSerializer.new(@space).serializable_hash, status: :created
        else
          render json: { errors: @space.errors }, status: :unprocessable_entity
        end
      end

      def update_occupancy
        authorize @space
        
        if @space.update_occupancy!(params[:occupancy])
          render json: SpaceSerializer.new(@space).serializable_hash
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
