class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # TODO : Delete hack to authorize Cross Request for js and json get request from javascript
  protect_from_forgery unless: -> { request.get? && (request.format.json? || request.format.js?) }
  before_action :authenticate_user!
  before_action :set_locale


  # Load helpers in rails engine
  helper LanguageEngine::Engine.helpers

  def set_locale
    # I18n.locale = session[:language] || I18n.default_locale
    # For testing different locales w/o restarting the server
    I18n.locale = (params['lang'] || session[:language] || I18n.default_locale).to_sym
    logger.info "locale set to #{I18n.locale.inspect}"
  end

  def pundit_user
    UserContext.new(current_user, referential: @referential)
  end

  protected

  def user_not_authorized
    redirect_to forbidden_path
  end

  def current_organisation
    current_user.organisation if current_user
  end
  helper_method :current_organisation

  def current_offer_workbench
    current_organisation.workbenches.find_by_name("Gestion de l'offre")
  end
  helper_method :current_offer_workbench

  def begin_of_association_chain
    current_organisation
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
