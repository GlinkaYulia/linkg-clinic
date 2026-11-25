# Послуга з каталогу клініки (аналог «товару» з методички)
class Service < ApplicationRecord
  belongs_to :specialty, optional: true
  has_many :appointment_services, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
end
