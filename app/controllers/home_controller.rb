class HomeController < ApplicationController
  skip_before_action :require_login

  def index
    if current_user&.admin?
      redirect_to admin_root_path
    elsif current_user&.doctor?
      @profile = current_user.doctor_profile
      @today = @profile ? @profile.appointments.scheduled.where(starts_at: Time.zone.now.all_day)
                                  .includes(:patient).order(:starts_at) : []
    elsif current_user&.patient?
      @next_visit = current_user.appointments.scheduled.where("starts_at > ?", Time.current)
                                .includes(doctor_profile: [:user, :specialty]).order(:starts_at).first
    else
      @specialties = Specialty.order(:name)
    end
  end
end
