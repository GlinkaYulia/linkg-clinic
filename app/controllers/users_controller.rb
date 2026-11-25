# Реєстрація пацієнта (FR-1, FR-2)
class UsersController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = :patient
    if @user.save
      cart = session[:cart]
      reset_session
      session[:cart] = cart if cart
      session[:user_id] = @user.id
      session[:last_seen_at] = Time.current.to_i
      redirect_to root_path, notice: "Реєстрацію завершено. Ласкаво просимо!"
    else
      render :new, status: 422
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :phone, :birth_date, :password, :password_confirmation)
  end
end
