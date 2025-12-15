class CompanyInformationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_company_information

  def admin
  end

  def update
    if @company_information.update(company_information_params)
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
      :additional_info
    )
  end
end
