class Specialty < ApplicationRecord
  has_many :doctor_profiles, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
