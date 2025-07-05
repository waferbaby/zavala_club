class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :handle_error

  def handle_error
    render :error
  end
end
