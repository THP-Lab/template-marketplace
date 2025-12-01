class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  def require_admin!
    authenticate_user!  # Devise vérifie le login

    unless current_user&.is_admin?
      redirect_to root_path, alert: "Accès refusé"
    end
  end 
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protected

  def configure_permitted_parameters
    additional_attrs = %i[first_name last_name address zipcode city country phone cgu_accepted]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: additional_attrs)
  end
end
