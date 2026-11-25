# Керування обліковими записами (FR-22, FR-23): створення, редагування, деактивація
module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:edit, :update]

    def index
      @users = User.order(:role, :full_name)
    end

    def new
      @user = User.new(role: :patient)
    end

    def create
      @user = User.new(user_params)
      @user.role = %w[patient admin].include?(params.dig(:user, :role)) ? params[:user][:role] : "patient"
      if @user.save
        redirect_to admin_users_path, notice: "Обліковий запис створено."
      else
        render :new, status: 422
      end
    end

    def edit
    end

    def update
      if @user == current_user && params.dig(:user, :active) == "0"
        flash.now[:alert] = "Не можна деактивувати власний обліковий запис."
        return render(:edit, status: 422)
      end
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Дані користувача оновлено."
      else
        render :edit, status: 422
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:full_name, :email, :phone, :birth_date, :active, :password, :password_confirmation)
    end
  end
end
