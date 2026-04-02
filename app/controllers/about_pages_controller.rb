class AboutPagesController < ApplicationController
  before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy, :admin, :update_settings ]
  before_action :set_company_information, only: [ :index, :admin, :update_settings ]
  before_action :set_about_page, only: %i[ edit update destroy ]

  # GET /about_pages or /about_pages.json
  def index
    load_about_collections
  end

  # GET /about_pages/new
  def new
    @about_page = AboutPage.new(section_type: selected_section_type)
  end

  # GET /about_pages/1/edit
  def edit
  end

  # POST /about_pages or /about_pages.json
  def create
    @about_page = AboutPage.new(about_page_params)

    respond_to do |format|
      if @about_page.save
        redirect_path = params[:redirect_to].presence || admin_about_pages_path(anchor: @about_page.section_type)
        format.html { redirect_to redirect_path, notice: "Bloc À propos créé." }
        format.json { render :show, status: :created, location: @about_page }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @about_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /about_pages/1 or /about_pages/1.json
  def update
    respond_to do |format|
      if @about_page.update(about_page_params)
        purge_about_page_image_if_requested
        redirect_path = params[:redirect_to].presence || edit_about_page_path(@about_page)
        format.html { redirect_to redirect_path, notice: "Bloc À propos mis à jour.", status: :see_other }
        format.json { render :show, status: :ok, location: @about_page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @about_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /about_pages/1 or /about_pages/1.json
  def destroy
    redirect_path = params[:redirect_to].presence || admin_about_pages_path(anchor: @about_page.section_type)

    respond_to do |format|
      if @about_page.destroy
        format.html { redirect_to redirect_path, notice: "Bloc À propos supprimé.", status: :see_other }
        format.json { head :no_content }
      else
        message = @about_page.errors.full_messages.to_sentence.presence || "Impossible de supprimer ce bloc À propos."
        format.html { redirect_to redirect_path, alert: message, status: :see_other }
        format.json { render json: { errors: @about_page.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::InvalidForeignKey
    respond_to do |format|
      message = "Impossible de supprimer ce bloc À propos car il est lié à d'autres données."
      format.html { redirect_to redirect_path, alert: message, status: :see_other }
      format.json { render json: { errors: [ message ] }, status: :unprocessable_entity }
    end
  end

  alias_method :admin, :index

  def update_settings
    if @company_information.update(about_settings_params)
      redirect_to admin_about_pages_path, notice: "Paramètres de la page À propos enregistrés."
    else
      flash.now[:alert] = "Impossible d'enregistrer les paramètres de la page À propos."
      load_about_collections
      render :admin, status: :unprocessable_entity
    end
  end

  def reorder
    require_admin!
    ids = params[:ids] || []
    AboutPage.transaction do
      ids.each_with_index do |id, idx|
        AboutPage.where(id: id).update_all(position: idx + 1)
      end
    end
    head :ok
  end

  private
    def set_company_information
      @company_information = CompanyInformation.instance
    end

    def load_about_collections
      @about_pages = AboutPage.order(:position, :created_at)
      @about_primary_blocks = @about_pages.where(section_type: AboutPage.section_types.fetch("primary"))
      @about_secondary_blocks = @about_pages.where(section_type: AboutPage.section_types.fetch("secondary"))
      @about_journey_blocks = @about_pages.where(section_type: AboutPage.section_types.fetch("journey"))
    end

    def selected_section_type
      candidate = params[:section_type].presence
      AboutPage.normalize_section_key(candidate).presence || "journey"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_about_page
      @about_page = AboutPage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def about_page_params
      permitted = params.expect(about_page: [ :title, :content, :position, :image, :section_type ])
      permitted[:section_type] = AboutPage.normalize_section_key(permitted[:section_type]).presence || "journey"
      permitted
    end

    def about_settings_params
      params.expect(company_information: [
        :about_primary_title,
        :about_primary_description,
        :about_secondary_title,
        :about_secondary_description,
        :about_journey_title,
        :about_journey_description
      ])
    end

    def purge_about_page_image_if_requested
      remove_image = ActiveModel::Type::Boolean.new.cast(params.dig(:about_page, :remove_image))
      new_image_uploaded = params.dig(:about_page, :image).present?
      return unless remove_image && !new_image_uploaded && @about_page.image.attached?

      @about_page.image.purge
    end
end
