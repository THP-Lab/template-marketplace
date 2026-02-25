class EventsController < ApplicationController
  before_action :require_admin!, only: [:new, :create, :edit, :update, :destroy, :admin]
  before_action :set_event, only: %i[ show edit update destroy ]

  # GET /events or /events.json
  def index
    scope = Event.order(event_date: :asc)
    unless action_name == "admin"
      scope = scope.where("(event_date IS NULL AND end_date IS NULL) OR COALESCE(end_date, event_date) >= ?", Time.current)
    end
    @events = scope
    @events, @pagination = paginate(@events) if action_name == "admin"
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = current_user.events.new(event_params)

    respond_to do |format|
      if @event.save
        redirect_path = params[:redirect_to].presence || new_event_path
        format.html { redirect_to redirect_path, notice: "Événement créé." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        redirect_path = params[:redirect_to].presence || edit_event_path(@event)
        format.html { redirect_to redirect_path, notice: "Événement mis à jour.", status: :see_other }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    redirect_path = params[:redirect_to].presence || admin_events_path

    respond_to do |format|
      if @event.destroy
        format.html { redirect_to redirect_path, notice: "Événement supprimé.", status: :see_other }
        format.json { head :no_content }
      else
        message = @event.errors.full_messages.to_sentence.presence || "Impossible de supprimer cet événement."
        format.html { redirect_to redirect_path, alert: message, status: :see_other }
        format.json { render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::InvalidForeignKey
    respond_to do |format|
      message = "Impossible de supprimer cet événement car il est lié à d'autres données."
      format.html { redirect_to redirect_path, alert: message, status: :see_other }
      format.json { render json: { errors: [message] }, status: :unprocessable_entity }
    end
  end

  alias_method :admin, :index

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.expect(event: [ :title, :category, :description, :event_date, :end_date, :location, :image_url, :image ])
    end
end
