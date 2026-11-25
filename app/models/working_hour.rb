class WorkingHour < ApplicationRecord
  WEEKDAYS = %w[Неділя Понеділок Вівторок Середа Четвер П’ятниця Субота].freeze
  TIME_FORMAT = /\A([01]\d|2[0-3]):(00|30)\z/

  belongs_to :doctor_profile

  validates :weekday, inclusion: { in: 0..6 },
                      uniqueness: { scope: :doctor_profile_id, message: "уже має розклад" }
  validates :start_time, :end_time,
            format: { with: TIME_FORMAT, message: "має бути у форматі ГГ:ХХ (хвилини 00 або 30)" }
  validate :end_after_start

  def weekday_name
    WEEKDAYS[weekday]
  end

  def start_minutes
    to_minutes(start_time)
  end

  def end_minutes
    to_minutes(end_time)
  end

  private

  def to_minutes(value)
    hours, minutes = value.to_s.split(":").map(&:to_i)
    hours * 60 + minutes
  end

  def end_after_start
    return unless start_time =~ TIME_FORMAT && end_time =~ TIME_FORMAT
    errors.add(:end_time, "має бути пізніше за початок роботи") if end_minutes <= start_minutes
  end
end
