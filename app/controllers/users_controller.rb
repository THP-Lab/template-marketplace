class UsersController < ApplicationController
  before_action :authenticate_user! 

  def show
    # On force la consultation du profil connecté uniquement
    @user = current_user
    @orders = @user.orders.order(created_at: :desc)
  end
end
