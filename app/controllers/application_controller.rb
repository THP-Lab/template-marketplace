class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def require_admin!
    authenticate_user!  # Devise vérifie le login

    unless current_user&.admin?
      redirect_to root_path, alert: "Accès refusé"
    end
  end 
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
