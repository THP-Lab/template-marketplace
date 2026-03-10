class OrdersController < ApplicationController
  before_action :require_admin!, only: [:admin]
  before_action :authenticate_user!, only: [:invoice, :index, :show, :new, :edit, :create, :update, :destroy]
  before_action :set_order, only: %i[ show edit update destroy invoice ]
  before_action :authorize_invoice!, only: [:invoice]

  # GET /orders or /orders.json
  def index
    if action_name == "admin"
      @filters = admin_order_filters
      @orders = filtered_admin_orders
      @orders, @pagination = paginate(@orders)
    else
      @orders = Order.all
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
    def admin_order_filters
      params.permit(:user_query, :status, :period, :sort).to_h
    end

    def filtered_admin_orders
      scope = Order.includes(:user, order_products: :product)
      scope = apply_user_filter(scope)
      scope = apply_status_filter(scope)
      scope = apply_period_filter(scope)
      apply_sort(scope)
    end

    def apply_user_filter(scope)
      query = @filters["user_query"].to_s.strip.downcase
      return scope if query.blank?

      term = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope.left_joins(:user).where(
        "LOWER(users.email) LIKE :term OR LOWER(users.first_name) LIKE :term OR LOWER(users.last_name) LIKE :term",
        term: term
      )
    end

    def apply_status_filter(scope)
      status = @filters["status"].to_s
      return scope if status.blank?
      return scope unless Order::STATUS_ORDER.include?(status)

      scope.where(status: status)
    end

    def apply_period_filter(scope)
      period = @filters["period"].to_s
      return scope if period.blank? || period == "all"

      case period
      when "today"
        scope.where("DATE(#{order_datetime_sql}) = ?", Time.zone.today)
      when "7d"
        scope.where("#{order_datetime_sql} >= ?", 7.days.ago.beginning_of_day)
      when "30d"
        scope.where("#{order_datetime_sql} >= ?", 30.days.ago.beginning_of_day)
      when "year"
        scope.where("#{order_datetime_sql} >= ?", Time.zone.today.beginning_of_year)
      else
        scope
      end
    end

    def apply_sort(scope)
      sort = @filters["sort"].to_s

      case sort
      when "date_asc"
        scope.order(Arel.sql("#{order_datetime_sql} ASC"))
      when "user_asc"
        scope.left_joins(:user).order(Arel.sql("LOWER(COALESCE(users.email, '')) ASC"), created_at: :desc)
      when "user_desc"
        scope.left_joins(:user).order(Arel.sql("LOWER(COALESCE(users.email, '')) DESC"), created_at: :desc)
      when "status_asc"
        scope.order(Arel.sql("#{status_order_sql} ASC"), created_at: :desc)
      when "status_desc"
        scope.order(Arel.sql("#{status_order_sql} DESC"), created_at: :desc)
      else
        scope.order(Arel.sql("#{order_datetime_sql} DESC"))
      end
    end

    def status_order_sql
      @status_order_sql ||= begin
        clauses = Order::STATUS_ORDER.each_with_index.map { |value, index| "WHEN '#{value}' THEN #{index}" }.join(" ")
        "CASE orders.status #{clauses} ELSE 999 END"
      end
    end

    def order_datetime_sql
      "COALESCE(orders.order_date, orders.created_at)"
    end

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
