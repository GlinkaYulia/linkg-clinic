# Рядок «кошика» оформленого візиту: послуга і її ціна на момент замовлення
class AppointmentService < ApplicationRecord
  belongs_to :appointment
  belongs_to :service

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :service_id, uniqueness: { scope: :appointment_id }
end
