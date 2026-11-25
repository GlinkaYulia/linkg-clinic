# Візити та оплата: перегляд усіх візитів, фільтри, підтвердження оплати
module Admin
  class AppointmentsController < BaseController
    def index
      scope = Appointment.includes(:patient, :services, doctor_profile: [:user, :specialty]).order(starts_at: :desc)
      scope = scope.where(status: params[:status]) if Appointment.statuses.key?(params[:status].to_s)
      scope = scope.where(payment_status: params[:payment_status]) if Appointment.payment_statuses.key?(params[:payment_status].to_s)
      @appointments = scope.limit(200)
    end

    def mark_paid
      appointment = Appointment.find(params[:id])
      if appointment.payment_unpaid? && !appointment.cancelled?
        appointment.mark_paid!
        redirect_back fallback_location: admin_appointments_path, notice: "Оплату підтверджено."
      else
        redirect_back fallback_location: admin_appointments_path, alert: "Для цього візиту підтвердити оплату неможливо."
      end
    end
  end
end
