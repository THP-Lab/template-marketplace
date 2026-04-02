class CompanyInformationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_company_information

  def admin
  end

  def footer
  end

  def shipping
  end

  def vat
  end

  def tabs
  end

  def home_banner
  end

  def streaming
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

  def update_shipping
    if @company_information.update(shipping_params)
      redirect_to shipping_company_information_path, notice: "Frais de port enregistrés."
    else
      flash.now[:alert] = "Impossible d'enregistrer les frais de port."
      render :shipping, status: :unprocessable_entity
    end
  end

  def update_vat
    if @company_information.update(vat_params)
      redirect_to vat_company_information_path, notice: "TVA enregistrée."
    else
      flash.now[:alert] = "Impossible d'enregistrer la TVA."
      render :vat, status: :unprocessable_entity
    end
  end

  def update_tabs
    if @company_information.update(tabs_params)
      redirect_to tabs_company_information_path, notice: "Titres des onglets enregistrés."
    else
      flash.now[:alert] = "Impossible d'enregistrer les titres des onglets."
      render :tabs, status: :unprocessable_entity
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

  def update_streaming
    if @company_information.update(streaming_params)
      flash[:notice] = "Configuration Twitch enregistrée."
      synchronize_twitch_configuration
      redirect_to streaming_company_information_path
    else
      flash.now[:alert] = "Impossible d'enregistrer la configuration Twitch."
      render :streaming, status: :unprocessable_entity
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
      :phone,
      :email,
      :additional_info
    )
  end

  def footer_params
    params.require(:company_information).permit(:footer_description)
  end

  def shipping_params
    params.require(:company_information).permit(
      { shipping_rates_attributes: [ :id, :destination_zone, :max_weight, :price, :_destroy ] }
    )
  end

  def vat_params
    params.require(:company_information).permit(:vat_number, :vat_rate)
  end

  def home_banner_params
    params.require(:company_information).permit(
      :home_banner_title,
      :home_banner_subtitle,
      :home_banner_primary_cta_label,
      :home_banner_secondary_cta_label,
      :home_banner_image,
      :home_highlight_1_title,
      :home_highlight_1_description,
      :home_highlight_2_title,
      :home_highlight_2_description,
      :home_highlight_3_title,
      :home_highlight_3_description,
      :home_highlight_4_title,
      :home_highlight_4_description
    )
  end

  def tabs_params
    params.require(:company_information).permit(
      :shop_page_title,
      :shop_page_subtitle,
      :events_page_title,
      :events_page_subtitle,
      :repair_page_title,
      :repair_page_subtitle,
      :contact_page_title,
      :contact_page_subtitle
    )
  end

  def streaming_params
    params.require(:company_information).permit(
      :twitch_live_enabled,
      :twitch_channel_login,
      :twitch_popup_title
    )
  end

  def purge_home_banner_image_if_requested
    remove_image = ActiveModel::Type::Boolean.new.cast(params.dig(:company_information, :remove_home_banner_image))
    new_image_uploaded = params.dig(:company_information, :home_banner_image).present?
    return unless remove_image && !new_image_uploaded && @company_information.home_banner_image.attached?

    @company_information.home_banner_image.purge_later
  end

  def synchronize_twitch_configuration
    message = Twitch::SubscriptionSync.call(
      company_information: @company_information,
      callback_base_url: request.base_url
    )

    flash[:notice] = [ flash[:notice], message ].compact.join(" ")
  rescue Twitch::Error => e
    flash[:alert] = e.message
  end
end
