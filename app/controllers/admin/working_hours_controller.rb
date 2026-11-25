# Розклад роботи лікаря: дні тижня, початок і кінець (слот — 30 хв)
module Admin
  class WorkingHoursController < BaseController
    before_action :set_profile

    def create
      hour = @profile.working_hours.build(params.require(:working_hour).permit(:weekday, :start_time, :end_time))
      if hour.save
        redirect_to edit_admin_doctor_path(@profile), notice: "Розклад додано."
      else
        redirect_to edit_admin_doctor_path(@profile), alert: hour.errors.full_messages.to_sentence
      end
    end

    def destroy
      @profile.working_hours.find(params[:id]).destroy
      redirect_to edit_admin_doctor_path(@profile), notice: "День видалено з розкладу."
    end

    private

    def set_profile
      @profile = DoctorProfile.find(params[:doctor_id])
    end
  end
end
