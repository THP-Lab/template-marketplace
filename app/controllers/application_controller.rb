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

  def after_sign_in_path_for(_resource)
    root_path
  end
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def paginate(scope, per_page: 10)
    page = params[:page].to_i
    page = 1 if page < 1

    total_count = scope.count
    total_pages = (total_count / per_page.to_f).ceil
    offset = (page - 1) * per_page

    records = scope.limit(per_page).offset(offset)
    pagination = {
      page: page,
      per_page: per_page,
      total_pages: total_pages,
      total_count: total_count
    }

    [records, pagination]
  end

  protected

  def configure_permitted_parameters
    additional_attrs = %i[first_name last_name address zipcode city country phone cgu_accepted]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: additional_attrs)
  end
end
