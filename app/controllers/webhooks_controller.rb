class WebhooksController < ApplicationController
  wrap_parameters false
  before_action :validate_request

  def index
    case params[:type]
    when 0
      head :no_content
    when 1
      render json: { type: 1 }
    end
  end

  private

  def validate_request
    verification_key = Ed25519::VerifyKey.new([ ENV["DISCORD_APP_PUBLIC_KEY"] ].pack("H*"))

    signature = request.headers["HTTP_X_SIGNATURE_ED25519"]
    timestamp = request.headers["HTTP_X_SIGNATURE_TIMESTAMP"]

    raise "Missing verification headers" unless signature.present? && timestamp.present?

    verification_key.verify([ signature ].pack("H*"), "#{timestamp}#{request.raw_post}")
  rescue StandardError => e
    Rails.logger.error("Failed to validate webhook request: #{e}")
    head :unauthorized
  end
end
