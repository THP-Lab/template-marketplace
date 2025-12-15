class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [:admin]
  before_action :set_user

  def show
    @orders = @user.orders.order(created_at: :desc)
  end

  def admin
    @users = User.order(created_at: :desc)
    @users, @pagination = paginate(@users)
  end

  def update
    require_admin! unless @user == current_user
    respond_to do |format|
      if @user.update(user_params)
        format.html do
          destination = params[:redirect_to].presence || user_path(@user)
          redirect_to destination, notice: "Profil mis à jour."
        end
      else
        @orders = @user.orders.order(created_at: :desc)
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    require_admin! unless @user == current_user
    @user.destroy
    sign_out(@user)
    redirect_to root_path, notice: "Votre compte a bien été supprimé."
  end

  private

  def set_user
    if current_user&.is_admin? && params[:id].present?
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :address,
      :zipcode,
      :city,
      :country,
      :phone
    )
  end
end
