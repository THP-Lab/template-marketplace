class CartProductsController < ApplicationController
  before_action :set_cart_product, only: %i[ show edit update destroy ]

  # GET /cart_products or /cart_products.json
  def index
    @cart_products = CartProduct.all
  end

  # GET /cart_products/1 or /cart_products/1.json
  def show
  end

  # GET /cart_products/new
  def new
    @cart_product = CartProduct.new
  end

  # GET /cart_products/1/edit
  def edit
  end

  # POST /cart_products or /cart_products.json
  def create
    cart = current_user.cart
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    cart_product = cart.cart_products.find_by(product_id: product.id)

    if cart_product
      cart_product.update(quantity: cart_product.quantity + quantity)
    else
      cart.cart_products.create(
        product: product,
        quantity: quantity,
        unit_price: product.price
      )
    end

    redirect_to product_path(product), notice: "Produit ajouté au panier."
  end

  # PATCH/PUT /cart_products/1 or /cart_products/1.json
  def update
    respond_to do |format|
      if @cart_product.update(cart_product_params)
        format.html { redirect_to @cart_product, notice: "Cart product was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @cart_product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cart_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cart_products/1 or /cart_products/1.json
  def destroy
    @cart_product.destroy!

    respond_to do |format|
      format.html { redirect_to cart_products_path, notice: "Cart product was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart_product
      @cart_product = CartProduct.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def cart_product_params
      params.expect(cart_product: [ :cart_id, :product_id, :quantity, :unit_price ])
    end
end
