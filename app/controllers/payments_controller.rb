# Онлайн-оплата візиту. УВАГА: імітація — реальний платіжний шлюз (LiqPay, Stripe тощо) не підключено.
# Дані картки перевіряються, але нікуди не зберігаються.
class PaymentsController < ApplicationController
  before_action -> { require_role(:patient) }
  before_action :set_appointment
  before_action :ensure_payable

  def new
  end

  def create
    @errors = card_errors
    if @errors.empty?
      @appointment.mark_paid!
      redirect_to appointments_path, notice: "Оплату прийнято. Номер платежу: #{@appointment.payment_reference}."
    else
      render :new, status: 422
    end
  end

  private

  def set_appointment
    @appointment = current_user.appointments.find(params[:appointment_id])
  end

  def ensure_payable
    return if @appointment.payable_online?
    redirect_to appointments_path, alert: "Для цього візиту онлайн-оплата недоступна."
  end

  def card_errors
    errors = []
    number = params[:card_number].to_s.delete(" ")
    errors << "Номер картки має містити 16 цифр і бути коректним." unless number.match?(/\A\d{16}\z/) && luhn_valid?(number)
    errors << "Термін дії вкажіть у форматі ММ/РР, картка не повинна бути прострочена." unless expiry_valid?(params[:expiry].to_s)
    errors << "CVV має містити 3 цифри." unless params[:cvv].to_s.match?(/\A\d{3}\z/)
    errors
  end

  # Алгоритм Луна — перевірка контрольної суми номера картки
  def luhn_valid?(number)
    sum = number.reverse.chars.map(&:to_i).each_with_index.sum do |digit, index|
      if index.odd?
        doubled = digit * 2
        doubled > 9 ? doubled - 9 : doubled
      else
        digit
      end
    end
    (sum % 10).zero?
  end

  def expiry_valid?(value)
    match = value.match(%r{\A(0[1-9]|1[0-2])/(\d{2})\z})
    return false unless match
    last_day = Date.new(2000 + match[2].to_i, match[1].to_i, 1).end_of_month
    last_day >= Date.current
  end
end
