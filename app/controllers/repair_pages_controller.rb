class RepairPagesController < ApplicationController
  before_action :require_admin!, only: [:new, :create, :edit, :update, :destroy, :admin]
  before_action :set_repair_page, only: %i[ edit update destroy ]

  # GET /repair_pages or /repair_pages.json
  def index
    @repair_pages = RepairPage.order(:position)
    if action_name == "admin"
      @repair_pages, @pagination = paginate(@repair_pages)
    end
  end

  # GET /repair_pages/new
  def new
    @repair_page = RepairPage.new
  end

  # GET /repair_pages/1/edit
  def edit
  end

  # POST /repair_pages or /repair_pages.json
  def create
    @repair_page = RepairPage.new(repair_page_params)

    respond_to do |format|
      if @repair_page.save
        format.html { redirect_to @repair_page, notice: "Repair page was successfully created." }
        format.json { render :show, status: :created, location: @repair_page }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @repair_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repair_pages/1 or /repair_pages/1.json
  def update
    respond_to do |format|
      if @repair_page.update(repair_page_params)
        format.html { redirect_to @repair_page, notice: "Repair page was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @repair_page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @repair_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repair_pages/1 or /repair_pages/1.json
  def destroy
    @repair_page.destroy!

    respond_to do |format|
      format.html { redirect_to repair_pages_path, notice: "Repair page was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  alias_method :admin, :index

  def reorder
    require_admin!
    ids = params[:ids] || []
    RepairPage.transaction do
      ids.each_with_index do |id, idx|
        RepairPage.where(id: id).update_all(position: idx + 1)
      end
    end
    head :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repair_page
      @repair_page = RepairPage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def repair_page_params
      params.expect(repair_page: [ :title, :content, :position, :image ])
    end
end
