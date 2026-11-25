class MedicalRecord < ApplicationRecord
  EDIT_WINDOW = 24 * 60 * 60   # редагувати можна протягом 24 годин

  belongs_to :appointment

  validates :complaints, :diagnosis, :prescription, presence: true

  def editable?
    created_at > Time.current - EDIT_WINDOW
  end
end
