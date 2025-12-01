class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @orders = @user.orders.order(created_at: :desc)
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profil mis à jour."
    else
      @orders = @user.orders.order(created_at: :desc)
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    sign_out(@user)
    redirect_to root_path, notice: "Votre compte a bien été supprimé."
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :address,
      :zipcode,
      :city,
      :country,
      :phone,
      :email
    )
  end
end
