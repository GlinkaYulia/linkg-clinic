# Профілі лікарів та їхні розклади (FR-24, FR-25)
module Admin
  class DoctorsController < BaseController
    before_action :set_profile, only: [:edit, :update]

    def index
      @doctors = DoctorProfile.includes(:user, :specialty, :working_hours).sort_by { |d| d.user.full_name }
    end

    def new
      @user = User.new
      @profile = DoctorProfile.new
    end

    def create
      @user = User.new(user_params)
      @user.role = :doctor
      @profile = DoctorProfile.new(profile_params)
      @profile.user = @user

      if @user.valid? & @profile.valid?
        ActiveRecord::Base.transaction do
          @user.save!
          @profile.save!
        end
        redirect_to edit_admin_doctor_path(@profile), notice: "Профіль лікаря створено. Тепер налаштуйте розклад."
      else
        render :new, status: 422
      end
    end

    def edit
      @user = @profile.user
    end

    def update
      @user = @profile.user
      ActiveRecord::Base.transaction do
        @user.update!(user_params)
        @profile.update!(profile_params)
      end
      redirect_to admin_doctors_path, notice: "Профіль лікаря оновлено."
    rescue ActiveRecord::RecordInvalid
      render :edit, status: 422
    end

    private

    def set_profile
      @profile = DoctorProfile.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:full_name, :email, :phone, :active, :password, :password_confirmation)
    end

    def profile_params
      params.require(:doctor_profile).permit(:specialty_id, :room, :bio, :consultation_price)
    end
  end
end
