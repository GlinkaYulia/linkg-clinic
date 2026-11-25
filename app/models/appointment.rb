class Appointment < ApplicationRecord
  CANCEL_LIMIT_SECONDS = 2 * 60 * 60   # скасувати можна не пізніше ніж за 2 години

  DELIVERY_LABELS = {
    "pickup" => "Отримати в реєстратурі клініки",
    "email"  => "Надіслати на електронну пошту",
    "post"   => "Надіслати поштою (Нова пошта)"
  }.freeze
  DELIVERY_FEES = { "pickup" => 0, "email" => 0, "post" => 60 }.freeze   # вартість доставки результатів, грн

  PAYMENT_METHOD_LABELS = {
    "cash"        => "Готівкою в клініці",
    "card_clinic" => "Карткою в клініці",
    "online"      => "Онлайн карткою"
  }.freeze
  PAYMENT_STATUS_LABELS = { "unpaid" => "Не оплачено", "paid" => "Оплачено", "refunded" => "Повернено" }.freeze

  belongs_to :patient, class_name: "User"
  belongs_to :doctor_profile
  has_one :medical_record, dependent: :destroy
  has_one :review, dependent: :destroy
  has_many :appointment_services, dependent: :destroy
  has_many :services, through: :appointment_services

  enum :status, { scheduled: 0, completed: 1, cancelled: 2 }
  enum :delivery_method, { pickup: 0, email: 1, post: 2 }, prefix: :delivery
  enum :payment_method, { cash: 0, card_clinic: 1, online: 2 }, prefix: :pay
  enum :payment_status, { unpaid: 0, paid: 1, refunded: 2 }, prefix: :payment

  scope :not_cancelled, -> { where.not(status: :cancelled) }

  validates :starts_at, presence: true
  validates :delivery_address, presence: { message: "потрібна для відправлення поштою" }, if: :delivery_post?
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validate :slot_rules, on: :create

  # Формує «замовлення»: рядки послуг із кошика, вартість доставки та загальну суму
  def prepare_order(services)
    services = services.to_a
    services.each { |service| appointment_services.build(service: service, price: service.price) }
    self.delivery_fee = DELIVERY_FEES.fetch(delivery_method.to_s, 0)
    self.total_price = doctor_profile.consultation_price + services.sum(&:price) + delivery_fee
    self.payment_status = :unpaid
    self
  end

  def cancellable?
    scheduled? && (starts_at - Time.current) >= CANCEL_LIMIT_SECONDS
  end

  # Скасування візиту; якщо було сплачено — оплата позначається як повернена
  def cancel!
    self.payment_status = :refunded if payment_paid?
    self.status = :cancelled
    self.cancelled_at = Time.current
    save!
  end

  def mark_paid!
    update!(payment_status: :paid, paid_at: Time.current,
            payment_reference: "LG-#{SecureRandom.hex(4).upcase}")
  end

  def payable_online?
    pay_online? && payment_unpaid? && !cancelled?
  end

  def reviewable?
    completed? && review.nil?
  end

  def delivery_label
    DELIVERY_LABELS[delivery_method]
  end

  def payment_method_label
    PAYMENT_METHOD_LABELS[payment_method]
  end

  def payment_status_label
    PAYMENT_STATUS_LABELS[payment_status]
  end

  private

  def slot_rules
    return if starts_at.blank? || doctor_profile.blank?

    errors.add(:base, "Не можна записатися на час, що вже минув.") if starts_at <= Time.current
    errors.add(:base, "Цей час не входить до розкладу лікаря.") unless doctor_profile.slot_in_schedule?(starts_at)
    if doctor_profile.appointments.not_cancelled.where(starts_at: starts_at).exists?
      errors.add(:base, "Цей час уже зайнятий.")
    end
    if Appointment.not_cancelled.where(patient_id: patient_id, starts_at: starts_at).exists?
      errors.add(:base, "У вас уже є візит на цей час.")
    end
  end
end
