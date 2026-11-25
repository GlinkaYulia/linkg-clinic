class User < ApplicationRecord
  has_secure_password

  ROLE_NAMES = { "patient" => "Пацієнт", "doctor" => "Лікар", "admin" => "Адміністратор" }.freeze

  enum :role, { patient: 0, doctor: 1, admin: 2 }

  MAX_FAILED_ATTEMPTS = 5
  LOCK_PERIOD = 15 * 60   # секунд

  has_one :doctor_profile, dependent: :destroy
  has_many :reviews, foreign_key: :patient_id, inverse_of: :patient, dependent: :destroy
  has_many :appointments, foreign_key: :patient_id, inverse_of: :patient, dependent: :restrict_with_error

  before_validation :normalize_email

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :birth_date, presence: true, if: :patient?
  validates :password, length: { minimum: 8 }, allow_nil: true

  scope :enabled, -> { where(active: true) }

  def role_name
    ROLE_NAMES[role]
  end

  # NFR-S6: після 5 невдалих спроб входу обліковий запис блокується на 15 хвилин
  def locked?
    locked_until.present? && locked_until > Time.current
  end

  def register_failed_attempt!
    attempts = failed_attempts + 1
    if attempts >= MAX_FAILED_ATTEMPTS
      update_columns(failed_attempts: 0, locked_until: Time.current + LOCK_PERIOD)
    else
      update_columns(failed_attempts: attempts)
    end
  end

  def reset_failed_attempts!
    return unless failed_attempts.positive? || locked_until
    update_columns(failed_attempts: 0, locked_until: nil)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
