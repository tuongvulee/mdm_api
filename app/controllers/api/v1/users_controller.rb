module Api
  module V1
    class UsersController < BaseController
      def index
        users = User.order(:id)
        render json: { data: UserSerializer.collection(users) }
      end

      def create
        user = User.create!(user_params)
        render json: { data: UserSerializer.new(user).as_json }, status: :created
      end

      private

      def user_params
        params.expect(user: %i[name email])
      end
    end
  end
end
