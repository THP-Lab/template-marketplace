class OrdersController < ApplicationController
  before_action :require_admin!, only: [:admin]
  before_action :authenticate_user!, only: [:invoice, :index, :show, :new, :edit, :create, :update, :destroy]
  before_action :set_order, only: %i[ show edit update destroy invoice ]
  before_action :authorize_invoice!, only: [:invoice]

  # GET /orders or /orders.json
  def index
    @orders = Order.all
    if action_name == "admin"
      @orders, @pagination = paginate(@orders)
    end
  end

  # GET /orders/1 or /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    @order = current_user.orders.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        redirect_path = params[:redirect_to].presence || @order
        format.html { redirect_to redirect_path, notice: "Order was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    respond_to do |format|
      format.html do
        redirect_to orders_path,
                    alert: "La suppression des commandes est désactivée.",
                    status: :see_other
      end
      format.json { head :method_not_allowed }
    end
  end

  alias_method :admin, :index

  def invoice
    company_information = CompanyInformation.instance
    pdf = InvoicePdf.new(@order, company_information)
    send_data pdf.render,
              filename: "facture-commande-#{@order.id}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.includes(:user, order_products: :product).find(params[:id])
    end

    def authorize_invoice!
      return if current_user&.is_admin? || @order.user_id == current_user&.id

      redirect_to root_path, alert: "Accès refusé"
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:order_date, :total_amount, :status, :tracking_number)
    end
end
