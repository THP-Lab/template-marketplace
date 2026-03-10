class RepairPartnersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_company_information, only: [:admin, :create, :update_section_title]
  before_action :set_repair_partner, only: [:edit, :update, :destroy]

  def admin
    @repair_partner = RepairPartner.new
    @repair_partners = RepairPartner.ordered.with_attached_logo
  end

  def create
    @repair_partner = RepairPartner.new(repair_partner_params)

    if @repair_partner.save
      redirect_to admin_repair_partners_path, notice: "Partenaire ajouté."
    else
      @repair_partners = RepairPartner.ordered.with_attached_logo
      flash.now[:alert] = "Impossible d'ajouter ce partenaire."
      render :admin, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @repair_partner.update(repair_partner_params)
      redirect_to admin_repair_partners_path, notice: "Partenaire mis à jour."
    else
      flash.now[:alert] = "Impossible de mettre à jour ce partenaire."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @repair_partner.destroy
    redirect_to admin_repair_partners_path, notice: "Partenaire supprimé.", status: :see_other
  end

  def update_section_title
    if @company_information.update(section_title_params)
      redirect_to admin_repair_partners_path, notice: "Titre de section enregistré."
    else
      @repair_partner = RepairPartner.new
      @repair_partners = RepairPartner.ordered.with_attached_logo
      flash.now[:alert] = "Impossible d'enregistrer le titre."
      render :admin, status: :unprocessable_entity
    end
  end

  private

  def set_company_information
    @company_information = CompanyInformation.instance
  end

  def set_repair_partner
    @repair_partner = RepairPartner.find(params.expect(:id))
  end

  def repair_partner_params
    params.expect(repair_partner: [:title, :url, :logo])
  end

  def section_title_params
    params.expect(company_information: [:repair_partners_section_title])
  end
end
