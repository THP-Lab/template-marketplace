class PrivacyPagesController < ApplicationController
  before_action :set_privacy_page, only: %i[ show edit update destroy ]

  # GET /privacy_pages or /privacy_pages.json
  def index
    @privacy_pages = PrivacyPage.all
  end

  # GET /privacy_pages/1 or /privacy_pages/1.json
  def show
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
