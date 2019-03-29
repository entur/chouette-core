class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  layout :layout

  def layout
    user_signed_in? ? 'application' : 'devise'
  end

  def not_found
    render status: 404
  end

  def server_error
    render status: 500
  end

  def forbidden
    render status: 403
  end
end
