# Медичний запис за результатами прийому (FR-17 … FR-20)
module Doctor
  class MedicalRecordsController < BaseController
    before_action :set_appointment

    def new
      return redirect_to(edit_doctor_appointment_medical_record_path(@appointment)) if @appointment.medical_record
      return redirect_to(doctor_schedule_path, alert: "Цей візит уже не можна провести.") unless @appointment.scheduled?
      @record = @appointment.build_medical_record
    end

    def create
      return redirect_to(doctor_schedule_path, alert: "Цей візит уже не можна провести.") unless @appointment.scheduled?
      @record = @appointment.build_medical_record(record_params)

      # FR-20: запис і зміна статусу — в одній транзакції
      Appointment.transaction do
        @record.save!
        @appointment.completed!
      end
      redirect_to doctor_schedule_path, notice: "Медичний запис збережено, візит завершено."
    rescue ActiveRecord::RecordInvalid
      render :new, status: 422
    end

    def edit
      @record = @appointment.medical_record || raise(ActiveRecord::RecordNotFound)
      unless @record.editable?
        redirect_to doctor_patient_path(@appointment.patient_id),
                    alert: "Редагувати запис можна лише протягом 24 годин після створення."
      end
    end

    def update
      @record = @appointment.medical_record || raise(ActiveRecord::RecordNotFound)
      unless @record.editable?
        return redirect_to(doctor_patient_path(@appointment.patient_id),
                           alert: "Редагувати запис можна лише протягом 24 годин після створення.")
      end
      if @record.update(record_params)
        redirect_to doctor_patient_path(@appointment.patient_id), notice: "Запис оновлено."
      else
        render :edit, status: 422
      end
    end

    private

    def set_appointment
      @appointment = @doctor_profile.appointments.includes(:patient).find(params[:appointment_id])
    end

    def record_params
      params.require(:medical_record).permit(:complaints, :diagnosis, :prescription)
    end
  end
end
