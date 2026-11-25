# Історія візитів, діагнози та призначення пацієнта (FR-14), лише перегляд
class HistoriesController < ApplicationController
  before_action -> { require_role(:patient) }

  def index
    @appointments = current_user.appointments.completed
                                .includes(:medical_record, :review, doctor_profile: [:user, :specialty])
                                .order(starts_at: :desc)
  end
end
