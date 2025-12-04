class AboutPagesController < ApplicationController
  before_action :set_about_page, only: %i[ show edit update destroy ]

  # GET /about_pages or /about_pages.json
  def index
    @about_pages = AboutPage.all
  end

  # GET /about_pages/1 or /about_pages/1.json
  def show
  end

  # GET /about_pages/new
  def new
    @about_page = AboutPage.new
  end

  # GET /about_pages/1/edit
  def edit
  end

  # POST /about_pages or /about_pages.json
  def create
    @about_page = AboutPage.new(about_page_params)

    respond_to do |format|
      if @about_page.save
        format.html { redirect_to @about_page, notice: "About page was successfully created." }
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
        format.html { redirect_to @about_page, notice: "About page was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @about_page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @about_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /about_pages/1 or /about_pages/1.json
  def destroy
    @about_page.destroy!

    respond_to do |format|
      format.html { redirect_to about_pages_path, notice: "About page was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_about_page
      @about_page = AboutPage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def about_page_params
      params.expect(about_page: [ :title, :content, :position ])
    end
end
