module Api
  module V1
    class DeviceStatusesController < BaseController
      def update
        device = Device.find(params[:device_id])
        device.update!(status: params[:status])
        render json: { data: DeviceSerializer.new(device).as_json }
      end
    end
  end
end
