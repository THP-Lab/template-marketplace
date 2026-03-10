class ProductsController < ApplicationController
  before_action :require_admin!, only: [:new, :create, :edit, :update, :destroy, :admin]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_available_company_documents, only: [:new, :edit, :create, :update]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /products or /products.json
  def index
    @categories = Product.distinct.where.not(category: [nil, ""]).order(:category).pluck(:category)
    @selected_category = params[:category]

    @products = Product.includes(image_attachment: :blob, images_attachments: :blob)
    @products = @products.where(category: @selected_category) if @selected_category.present?
    if action_name == "admin"
      @products, @pagination = paginate(@products)
    end
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    attributes = product_params
    @product = Product.new(attributes.except(:images, :remove_image_attachment_ids))

    respond_to do |format|
      if @product.save
        attach_product_images(attributes)
        redirect_path = params[:redirect_to].presence || new_product_path
        format.html { redirect_to redirect_path, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    attributes = product_params
    remove_ids = Array(attributes[:remove_image_attachment_ids])

    respond_to do |format|
      if @product.update(attributes.except(:images, :remove_image_attachment_ids))
        purge_product_images(remove_ids)
        attach_product_images(attributes)
        redirect_path = params[:redirect_to].presence || edit_product_path(@product)
        format.html { redirect_to redirect_path, notice: "Product was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    redirect_path = params[:redirect_to].presence || admin_products_path

    respond_to do |format|
      if @product.destroy
        format.html { redirect_to redirect_path, notice: "Produit supprimé.", status: :see_other }
        format.json { head :no_content }
      else
        message = @product.errors.full_messages.to_sentence.presence || "Impossible de supprimer ce produit."
        format.html { redirect_to redirect_path, alert: message, status: :see_other }
        format.json { render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::InvalidForeignKey
    respond_to do |format|
      message = "Impossible de supprimer ce produit car il est lié à des commandes."
      format.html { redirect_to redirect_path, alert: message, status: :see_other }
      format.json { render json: { errors: [message] }, status: :unprocessable_entity }
    end
  end

  alias_method :admin, :index

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.includes(image_attachment: :blob, images_attachments: :blob).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [
        :title,
        :description,
        :category,
        :price,
        :stock,
        :image,
        { images: [] },
        { remove_image_attachment_ids: [] },
        :show_product_highlights,
        :highlight_1_enabled,
        :highlight_2_enabled,
        :highlight_3_enabled,
        :highlight_1_document_enabled,
        :highlight_2_document_enabled,
        :highlight_3_document_enabled,
        :highlight_1_company_document_id,
        :highlight_2_company_document_id,
        :highlight_3_company_document_id,
        :highlight_1_title,
        :highlight_1_description,
        :highlight_2_title,
        :highlight_2_description,
        :highlight_3_title,
        :highlight_3_description
      ])
    end

    def attach_product_images(attributes)
      uploaded_images = Array(attributes[:images]).reject(&:blank?)
      return if uploaded_images.empty?

      @product.images.attach(uploaded_images)
    end

    def purge_product_images(attachment_ids)
      ids = Array(attachment_ids).reject(&:blank?).map(&:to_i)
      return if ids.empty?

      removable_attachments = @product.gallery_images.select { |attachment| ids.include?(attachment.id) }
      removable_attachments.each(&:purge_later)
    end

    def set_available_company_documents
      @available_company_documents = CompanyInformation.instance.company_documents.ordered
    end
end
