class CompanyInformationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_company_information

  def admin
  end

  def update
    if @company_information.update(company_information_params)
      purge_home_banner_image_if_requested
      redirect_to admin_company_information_path, notice: "Informations enregistrées."
    else
      flash.now[:alert] = "Impossible d'enregistrer ces informations."
      render :admin, status: :unprocessable_entity
    end
  end

  private

  def set_company_information
    @company_information = CompanyInformation.instance
  end

  def company_information_params
    params.require(:company_information).permit(
      :legal_name,
      :address_line1,
      :address_line2,
      :zipcode,
      :city,
      :country,
      :siret,
      :vat_number,
      :phone,
      :email,
      :additional_info,
      :home_banner_title,
      :home_banner_subtitle,
      :home_banner_primary_cta_label,
      :home_banner_secondary_cta_label,
      :home_banner_image
    )
  end

  def purge_home_banner_image_if_requested
    remove_image = ActiveModel::Type::Boolean.new.cast(params.dig(:company_information, :remove_home_banner_image))
    new_image_uploaded = params.dig(:company_information, :home_banner_image).present?
    return unless remove_image && !new_image_uploaded && @company_information.home_banner_image.attached?

    @company_information.home_banner_image.purge_later
  end
end
