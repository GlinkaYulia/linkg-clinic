# Відгук пацієнта про лікаря після завершеного візиту
class Review < ApplicationRecord
  belongs_to :appointment
  belongs_to :patient, class_name: "User"
  belongs_to :doctor_profile

  enum :status, { published: 0, hidden: 1 }

  validates :rating, inclusion: { in: 1..5, message: "має бути від 1 до 5" }
  validates :body, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :appointment_id, uniqueness: { message: "вже має відгук" }
end
