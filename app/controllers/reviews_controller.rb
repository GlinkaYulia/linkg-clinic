# Відгук пацієнта про лікаря після завершеного візиту
class ReviewsController < ApplicationController
  before_action -> { require_role(:patient) }
  before_action :set_appointment

  def new
    @review = Review.new(rating: 5)
  end

  def create
    @review = Review.new(review_params.merge(appointment: @appointment, patient: current_user,
                                             doctor_profile: @appointment.doctor_profile))
    if @review.save
      redirect_to history_path, notice: "Дякуємо за відгук!"
    else
      render :new, status: 422
    end
  end

  private

  def set_appointment
    @appointment = current_user.appointments.completed.includes(doctor_profile: [:user, :specialty])
                               .find(params[:appointment_id])
    redirect_to history_path, alert: "Відгук про цей візит уже залишено." if @appointment.review
  end

  def review_params
    params.require(:review).permit(:rating, :body)
  end
end
