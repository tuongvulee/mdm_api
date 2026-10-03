module Api
  module V1
    class DevicesController < BaseController
      def index
        devices = Device
          .for_user(params[:user_id])
          .with_status(params[:status])
          .on_platform(params[:platform])
          .order(:id)

        render json: { data: DeviceSerializer.collection(devices) }
      end

      def create
        device = Device.create!(device_params)
        render json: { data: DeviceSerializer.new(device).as_json }, status: :created
      end

      private

      def device_params
        params.expect(device: %i[user_id name platform serial_number])
      end
    end
  end
end
