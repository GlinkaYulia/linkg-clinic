# Зміна пароля та контактних даних (FR-6)
class ProfilesController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Дані профілю збережено."
    else
      render :show, status: 422
    end
  end

  private

  def profile_params
    params.require(:user).permit(:full_name, :phone, :email, :password, :password_confirmation)
  end
end
