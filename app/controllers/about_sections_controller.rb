class AboutSectionsController < ApplicationController
  before_action :set_about_section, only: %i[ show edit update destroy ]

  # GET /about_sections or /about_sections.json
  def index
    @about_sections = AboutSection.all
  end

  # GET /about_sections/1 or /about_sections/1.json
  def show
  end

  # GET /about_sections/new
  def new
    @about_section = AboutSection.new
  end

  # GET /about_sections/1/edit
  def edit
  end

  # POST /about_sections or /about_sections.json
  def create
    @about_section = AboutSection.new(about_section_params)

    respond_to do |format|
      if @about_section.save
        format.html { redirect_to @about_section, notice: "About section was successfully created." }
        format.json { render :show, status: :created, location: @about_section }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @about_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /about_sections/1 or /about_sections/1.json
  def update
    respond_to do |format|
      if @about_section.update(about_section_params)
        format.html { redirect_to @about_section, notice: "About section was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @about_section }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @about_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /about_sections/1 or /about_sections/1.json
  def destroy
    @about_section.destroy!

    respond_to do |format|
      format.html { redirect_to about_sections_path, notice: "About section was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_about_section
      @about_section = AboutSection.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def about_section_params
      params.expect(about_section: [ :title, :content, :position ])
    end
end
