class RepairSectionsController < ApplicationController
  before_action :require_admin!, except: %i[index show]
  before_action :set_repair_section, only: %i[ show edit update destroy ]

  # GET /repair_sections or /repair_sections.json
  def index
    @repair_sections = RepairSection.all
  end

  # GET /repair_sections/1 or /repair_sections/1.json
  def show
  end

  # GET /repair_sections/new
  def new
    @repair_section = RepairSection.new
  end

  # GET /repair_sections/1/edit
  def edit
  end

  # POST /repair_sections or /repair_sections.json
  def create
    @repair_section = RepairSection.new(repair_section_params)

    respond_to do |format|
      if @repair_section.save
        format.html { redirect_to @repair_section, notice: "Repair section was successfully created." }
        format.json { render :show, status: :created, location: @repair_section }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @repair_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repair_sections/1 or /repair_sections/1.json
  def update
    respond_to do |format|
      if @repair_section.update(repair_section_params)
        format.html { redirect_to @repair_section, notice: "Repair section was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @repair_section }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @repair_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repair_sections/1 or /repair_sections/1.json
  def destroy
    @repair_section.destroy!

    respond_to do |format|
      format.html { redirect_to repair_sections_path, notice: "Repair section was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repair_section
      @repair_section = RepairSection.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def repair_section_params
      params.expect(repair_section: [ :title, :content, :position ])
    end
end
