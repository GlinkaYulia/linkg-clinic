# Пацієнти лікаря та повна історія хвороби (FR-16, FR-21)
module Doctor
  class PatientsController < BaseController
    def index
      @patients = User.where(id: @doctor_profile.appointments.select(:patient_id)).order(:full_name)
      @visit_counts = @doctor_profile.appointments.group(:patient_id).count
    end

    def show
      @patient = User.find(params[:id])
      # FR-21: лікар не бачить пацієнтів, які ніколи не були записані до нього
      unless @doctor_profile.appointments.exists?(patient_id: @patient.id)
        return render("errors/forbidden", status: :forbidden)
      end
      # Повна історія — записи всіх лікарів
      @history = @patient.appointments.completed
                         .includes(:medical_record, doctor_profile: [:user, :specialty])
                         .order(starts_at: :desc)
    end
  end
end
