module Api
  module V1
    class BookingsController < BaseController
      before_action :set_booking, only: [:show, :update, :destroy]

      def index
        @bookings = current_user.admin? ? Booking.all : current_user.bookings
        @bookings = @bookings.includes(:space, :user)

        render json: BookingSerializer.new(@bookings, include: [:space]).serializable_hash
      end

      def create
        @booking = current_user.bookings.build(booking_params)

        if @booking.save
          render json: BookingSerializer.new(@booking).serializable_hash, status: :created
        else
          render json: { errors: @booking.errors }, status: :unprocessable_entity
        end
      end

      def update
        authorize @booking
        
        if @booking.update(booking_params)
          render json: BookingSerializer.new(@booking).serializable_hash
        else
          render json: { errors: @booking.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_booking
        @booking = Booking.find(params[:id])
      end

      def booking_params
        params.require(:booking).permit(:space_id, :start_time, :end_time, :notes)
      end
    end
  end
end
