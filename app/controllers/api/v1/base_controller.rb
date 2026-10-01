module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_validation_failed
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      private

      def render_not_found(exception)
        render_error(
          status: :not_found,
          code: "not_found",
          message: "#{exception.model || 'Record'} not found"
        )
      end

      def render_validation_failed(exception)
        render_error(
          status: :unprocessable_content,
          code: "validation_failed",
          message: "Validation failed",
          details: exception.record.errors.to_hash
        )
      end

      def render_bad_request(exception)
        render_error(status: :bad_request, code: "bad_request", message: exception.message)
      end

      def render_error(status:, code:, message:, details: nil)
        render json: { error: { code:, message:, details: }.compact }, status:
      end
    end # class BaseController
  end # module V1
end # module Api
