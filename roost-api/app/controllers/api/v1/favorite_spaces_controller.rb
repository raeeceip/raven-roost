module Api
  module V1
    class FavoriteSpacesController < BaseController
      def index
        @favorites = current_user.favorite_spaces.includes(:space)
        render json: FavoriteSpaceSerializer.new(@favorites, include: [:space]).serializable_hash
      end

      def create
        @favorite = current_user.favorite_spaces.build(favorite_params)

        if @favorite.save
          render json: FavoriteSpaceSerializer.new(@favorite).serializable_hash, status: :created
        else
          render json: { errors: @favorite.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @favorite = current_user.favorite_spaces.find(params[:id])
        @favorite.destroy
        head :no_content
      end

      private

      def favorite_params
        params.require(:favorite_space).permit(:space_id)
      end
    end
  end
end
