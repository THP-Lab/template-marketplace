class TermsPagesController < ApplicationController
  before_action :require_admin!, only: [:new, :create, :edit, :update, :destroy, :admin]
  before_action :set_terms_page, only: %i[ edit update destroy ]

  # GET /terms_pages or /terms_pages.json
  def index
    @terms_pages = TermsPage.order(:position)
    if action_name == "admin"
      @terms_pages, @pagination = paginate(@terms_pages)
    end
  end

  # GET /terms_pages/new
  def new
    @terms_page = TermsPage.new
  end

  # GET /terms_pages/1/edit
  def edit
  end

  # POST /terms_pages or /terms_pages.json
  def create
    @terms_page = TermsPage.new(terms_page_params)

    respond_to do |format|
      if @terms_page.save
        format.html { redirect_to @terms_page, notice: "Terms page was successfully created." }
        format.json { render :show, status: :created, location: @terms_page }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @terms_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /terms_pages/1 or /terms_pages/1.json
  def update
    respond_to do |format|
      if @terms_page.update(terms_page_params)
        format.html { redirect_to @terms_page, notice: "Terms page was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @terms_page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @terms_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /terms_pages/1 or /terms_pages/1.json
  def destroy
    @terms_page.destroy!

    respond_to do |format|
      format.html { redirect_to terms_pages_path, notice: "Terms page was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  alias_method :admin, :index

  def reorder
    require_admin!
    ids = params[:ids] || []
    TermsPage.transaction do
      ids.each_with_index do |id, idx|
        TermsPage.where(id: id).update_all(position: idx + 1)
      end
    end
    head :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_terms_page
      @terms_page = TermsPage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def terms_page_params
      params.expect(terms_page: [ :title, :content, :position ])
    end
end
