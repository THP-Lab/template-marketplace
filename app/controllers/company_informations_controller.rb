class CompanyInformationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_company_information

  def admin
  end

  def footer
  end

  def home_banner
  end

  def update
    if @company_information.update(company_information_params)
      redirect_to admin_company_information_path, notice: "Informations enregistrées."
    else
      flash.now[:alert] = "Impossible d'enregistrer ces informations."
      render :admin, status: :unprocessable_entity
    end
  end

  def update_footer
    if @company_information.update(footer_params)
      redirect_to footer_company_information_path, notice: "Description du footer enregistrée."
    else
      flash.now[:alert] = "Impossible d'enregistrer la description du footer."
      render :footer, status: :unprocessable_entity
    end
  end

  def update_home_banner
    if @company_information.update(home_banner_params)
      purge_home_banner_image_if_requested
      redirect_to home_banner_company_information_path, notice: "Bannière d’accueil enregistrée."
    else
      flash.now[:alert] = "Impossible d'enregistrer la bannière d’accueil."
      render :home_banner, status: :unprocessable_entity
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
      :additional_info
    )
  end

  def footer_params
    params.require(:company_information).permit(:footer_description)
  end

  def home_banner_params
    params.require(:company_information).permit(
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
