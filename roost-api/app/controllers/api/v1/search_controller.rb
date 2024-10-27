module Api
  module V1
    class SearchController < BaseController
      skip_before_action :authenticate_user!, only: [:index]

      def index
        @spaces = Space.search_spaces(
          params[:query],
          {
            building: params[:building],
            status: params[:status],
            min_capacity: params[:min_capacity],
            available_now: params[:available_now],
            page: params[:page]
          }
        )

        render json: {
          spaces: SpaceSerializer.new(@spaces).serializable_hash,
          meta: {
            total_count: @spaces.total_count,
            total_pages: @spaces.total_pages,
            current_page: @spaces.current_page,
            aggregations: @spaces.aggs
          }
        }
      end

      def suggest
        suggestions = Space.search(
          params[:term],
          fields: [{name: :word_start}],
          limit: 5,
          suggest: true
        ).suggestions

        render json: suggestions
      end
    end
  end
end
