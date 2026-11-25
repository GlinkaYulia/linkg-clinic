# Оформлення візиту (запис + послуги з кошика + доставка результатів + оплата),
# список і скасування візитів пацієнта (FR-9 … FR-13)
class AppointmentsController < ApplicationController
  before_action -> { require_role(:patient) }
  before_action :set_doctor_and_time, only: [:new, :create]

  def index
    scope = current_user.appointments.includes(:review, doctor_profile: [:user, :specialty])
    @upcoming = scope.where("starts_at >= ?", Time.current).order(:starts_at)
    @past = scope.where("starts_at < ?", Time.current).order(starts_at: :desc)
  end

  # Крок «Оформлення»: підсумок замовлення, вибір доставки результатів і способу оплати
  def new
    @appointment = current_user.appointments.build(doctor_profile: @doctor, starts_at: @starts_at,
                                                   delivery_method: :pickup, payment_method: :cash)
  end

  def create
    @appointment = current_user.appointments.build(checkout_params.merge(doctor_profile: @doctor, starts_at: @starts_at))
    @appointment.prepare_order(cart_services)

    if @appointment.save
      session[:cart] = []
      if @appointment.payable_online?
        redirect_to new_appointment_payment_path(@appointment), notice: "Візит оформлено. Залишилося оплатити."
      else
        redirect_to appointments_path,
                    notice: "Ви записані до лікаря #{@doctor.full_name} на #{helpers.fmt_dt(@starts_at)}."
      end
    else
      render :new, status: 422
    end
  rescue ActiveRecord::RecordNotUnique
    # FR-10: подвійне бронювання блокує унікальний індекс у БД
    redirect_to doctor_path(@doctor), alert: "Цей час щойно зайняв інший пацієнт. Оберіть інший слот."
  end

  def cancel
    appointment = current_user.appointments.find(params[:id])
    if appointment.cancellable?
      appointment.cancel!
      notice = appointment.payment_refunded? ? "Візит скасовано. Кошти буде повернуто." : "Візит скасовано."
      redirect_to appointments_path, notice: notice
    else
      redirect_to appointments_path, alert: "Скасувати візит можна не пізніше ніж за 2 години до початку."
    end
  end

  private

  def set_doctor_and_time
    @doctor = DoctorProfile.find(params[:doctor_id])
    @starts_at = Time.zone.parse(params[:starts_at].to_s)
    if @starts_at.nil? || !@doctor.slot_available?(@starts_at)
      redirect_to doctor_path(@doctor), alert: "Цей час недоступний. Оберіть інший слот."
    end
  end

  # Дозволяються лише відомі значення enum, інакше — значення за замовчуванням
  def checkout_params
    permitted = params.fetch(:appointment, {}).permit(:delivery_method, :delivery_address, :payment_method, :comment)
    permitted[:delivery_method] = "pickup" unless Appointment.delivery_methods.key?(permitted[:delivery_method].to_s)
    permitted[:payment_method] = "cash" unless Appointment.payment_methods.key?(permitted[:payment_method].to_s)
    permitted
  end
end
