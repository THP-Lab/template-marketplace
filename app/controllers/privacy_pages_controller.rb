class PrivacyPagesController < ApplicationController
  before_action :require_admin!, only: [:new, :create, :edit, :update, :destroy, :admin]
  before_action :set_privacy_page, only: %i[ edit update destroy ]

  # GET /privacy_pages or /privacy_pages.json
  def index
    @privacy_pages = PrivacyPage.order(:position)
    if action_name == "admin"
      @privacy_pages, @pagination = paginate(@privacy_pages)
    end
  end

  # GET /privacy_pages/new
  def new
    @privacy_page = PrivacyPage.new
  end

  # GET /privacy_pages/1/edit
  def edit
  end

  # POST /privacy_pages or /privacy_pages.json
  def create
    @privacy_page = PrivacyPage.new(privacy_page_params)

    respond_to do |format|
      if @privacy_page.save
        format.html { redirect_to @privacy_page, notice: "Privacy page was successfully created." }
        format.json { render :show, status: :created, location: @privacy_page }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @privacy_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /privacy_pages/1 or /privacy_pages/1.json
  def update
    respond_to do |format|
      if @privacy_page.update(privacy_page_params)
        format.html { redirect_to @privacy_page, notice: "Privacy page was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @privacy_page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @privacy_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /privacy_pages/1 or /privacy_pages/1.json
  def destroy
    @privacy_page.destroy!

    respond_to do |format|
      format.html { redirect_to privacy_pages_path, notice: "Privacy page was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  alias_method :admin, :index

  def reorder
    require_admin!
    ids = params[:ids] || []
    PrivacyPage.transaction do
      ids.each_with_index do |id, idx|
        PrivacyPage.where(id: id).update_all(position: idx + 1)
      end
    end
    head :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_privacy_page
      @privacy_page = PrivacyPage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def privacy_page_params
      params.expect(privacy_page: [ :title, :content, :position ])
    end
end
