class OrderProductsController < ApplicationController
  before_action :require_admin!, only: [:admin]
  before_action :set_order_product, only: %i[ show edit update destroy ]

  # GET /order_products or /order_products.json
  def index
    @order_products = OrderProduct.all
    if action_name == "admin"
      @order_products, @pagination = paginate(@order_products)
    end
  end

  # GET /order_products/1 or /order_products/1.json
  def show
  end

  # GET /order_products/new
  def new
    @order_product = OrderProduct.new
  end

  # GET /order_products/1/edit
  def edit
  end

  # POST /order_products or /order_products.json
  def create
    @order_product = OrderProduct.new(order_product_params)

    respond_to do |format|
      if @order_product.save
        format.html { redirect_to @order_product, notice: "Order product was successfully created." }
        format.json { render :show, status: :created, location: @order_product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_products/1 or /order_products/1.json
  def update
    respond_to do |format|
      if @order_product.update(order_product_params)
        format.html { redirect_to @order_product, notice: "Order product was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order_product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_products/1 or /order_products/1.json
  def destroy
    @order_product.destroy!

    respond_to do |format|
      format.html { redirect_to order_products_path, notice: "Order product was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  alias_method :admin, :index

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_product
      @order_product = OrderProduct.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def order_product_params
      params.expect(order_product: [ :order_id, :product_id, :quantity, :unit_price ])
    end
end
