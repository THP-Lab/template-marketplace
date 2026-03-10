class CartProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [:admin]
  before_action :set_cart_product, only: %i[ show edit update destroy ]

  # GET /cart_products or /cart_products.json
  def index
    if action_name == "admin"
      cart_scope = Cart.includes(:user, cart_products: :product).order(created_at: :desc)
      @carts, @pagination = paginate(cart_scope)
    else
      @cart_products = CartProduct.includes(:cart, :product).all
    end
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
    cart = current_user.cart || current_user.create_cart!(status: "open")
    product = Product.includes(product_options: :product_option_values).find(params[:product_id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    selected_options, selection_errors = product.build_option_selection_snapshot(selected_option_values_params)
    if selection_errors.any?
      redirect_to product_path(product), alert: selection_errors.join(" ") and return
    end

    unit_price = product.price.to_d + product.option_price_delta(selected_options)
    selected_options_signature = CartProduct.signature_for(selected_options)
    cart_product = cart.cart_products.find_by(
      product_id: product.id,
      selected_options_signature: selected_options_signature
    )

    if cart_product
      cart_product.update(quantity: cart_product.quantity + quantity)
    else
      cart.cart_products.create(
        product: product,
        quantity: quantity,
        unit_price: unit_price,
        selected_options: selected_options,
        selected_options_signature: selected_options_signature
      )
    end

    case params[:redirect_to]
    when "products"
      redirect_to products_path, notice: "Produit ajouté au panier."
    when "cart"
      redirect_to cart_path(cart), notice: "Produit ajouté au panier."
    when "product"
      redirect_to product_path(product), notice: "Produit ajouté au panier."
    else
      redirect_back fallback_location: products_path, notice: "Produit ajouté au panier."
    end
  end

  # PATCH/PUT /cart_products/1 or /cart_products/1.json
  def update
    cart = current_user.cart
    quantity = cart_product_params[:quantity].to_i
    notice = nil
    alert = nil

    if quantity <= 0
      @cart_product.destroy
      notice = "Produit retiré du panier."
    elsif @cart_product.update(quantity: quantity)
      notice = "Quantité mise à jour."
    else
      alert = "Impossible de mettre à jour cet article."
    end

    respond_to do |format|
      format.turbo_stream { render_cart_update(cart, notice:, alert:) }
      format.html do
        if alert
          redirect_to cart_path(cart), alert: alert
        else
          redirect_to cart_path(cart), notice: notice
        end
      end
    end
  end

  # DELETE /cart_products/1 or /cart_products/1.json
  def destroy
    cart = current_user.cart
    @cart_product.destroy!

    respond_to do |format|
      format.turbo_stream { render_cart_update(cart, notice: "Produit supprimé du panier.") }
      format.html { redirect_to cart_path(cart), notice: "Produit supprimé du panier." }
    end
  end

  alias_method :admin, :index

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart_product
      @cart_product = CartProduct.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def cart_product_params
      params.require(:cart_product).permit(:quantity)
    end

    def render_cart_update(cart, notice: nil, alert: nil)
      @cart_products = cart.cart_products.includes(:product)
      flash.now[:notice] = notice if notice
      flash.now[:alert] = alert if alert
      render turbo_stream: turbo_stream.replace(
        "cart_contents",
        partial: "carts/cart_contents",
        locals: { cart_products: @cart_products }
      )
    end

    def selected_option_values_params
      raw = params[:selected_option_values]
      return raw.to_h if raw.is_a?(Hash)
      return {} unless raw.respond_to?(:to_unsafe_h)

      raw.to_unsafe_h
    end
end
