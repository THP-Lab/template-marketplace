class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @orders = @user.orders.order(created_at: :desc)
  end

  def update
    @user = current_user
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

  private

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
