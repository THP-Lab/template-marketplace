class HomePagesController < ApplicationController
  before_action :set_home_page, only: %i[ show edit update destroy ]

  # GET /home_pages or /home_pages.json
  def index
    @home_pages = HomePage.all
    @featured_products = Product.order(Arel.sql("RANDOM()")).limit(5).to_a
  end

  # GET /home_pages/1 or /home_pages/1.json
  def show
  end

  # GET /home_pages/new
  def new
    @home_page = HomePage.new
  end

  # GET /home_pages/1/edit
  def edit
  end

  # POST /home_pages or /home_pages.json
  def create
    @home_page = HomePage.new(home_page_params)

    respond_to do |format|
      if @home_page.save
        format.html { redirect_to @home_page, notice: "Home page was successfully created." }
        format.json { render :show, status: :created, location: @home_page }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @home_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /home_pages/1 or /home_pages/1.json
  def update
    respond_to do |format|
      if @home_page.update(home_page_params)
        format.html { redirect_to @home_page, notice: "Home page was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @home_page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @home_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /home_pages/1 or /home_pages/1.json
  def destroy
    @home_page.destroy!

    respond_to do |format|
      format.html { redirect_to home_pages_path, notice: "Home page was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_home_page
      @home_page = HomePage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def home_page_params
      params.expect(home_page: [ :title, :content, :position ])
    end
end
