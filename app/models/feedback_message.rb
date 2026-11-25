# Звернення через форму зворотного зв’язку
class FeedbackMessage < ApplicationRecord
  belongs_to :user, optional: true

  enum :status, { pending: 0, answered: 1 }

  before_validation { self.email = email.to_s.strip.downcase }

  validates :name, :subject, :body, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :body, length: { maximum: 2000 }
end
