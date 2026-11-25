# Зведена панель: візити на сьогодні та завантаженість лікарів (FR-27)
module Admin
  class DashboardController < BaseController
    def index
      today = Time.zone.now.all_day
      @today_count = Appointment.scheduled.where(starts_at: today).count
      @patients_count = User.patient.enabled.count
      @doctors_count = DoctorProfile.count
      month = Time.zone.now.all_month
      @revenue = Appointment.payment_paid.where(paid_at: month).sum(:total_price)
      @pending_feedback = FeedbackMessage.pending.count
      @unpaid_online = Appointment.pay_online.payment_unpaid.not_cancelled.count

      today_counts = Appointment.scheduled.where(starts_at: today).group(:doctor_profile_id).count
      week_counts = Appointment.scheduled.where(starts_at: Time.current..7.days.from_now)
                               .group(:doctor_profile_id).count
      @load = DoctorProfile.includes(:user, :specialty, :working_hours).sort_by { |d| d.user.full_name }.map do |doctor|
        { doctor: doctor,
          today: today_counts[doctor.id].to_i,
          capacity: doctor.capacity_on(Date.current),
          week: week_counts[doctor.id].to_i }
      end
    end
  end
end
