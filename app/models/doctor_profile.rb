class DoctorProfile < ApplicationRecord
  SLOT_MINUTES = 30   # тривалість прийому
  SLOT_DAYS = 14      # на скільки днів уперед показуємо слоти

  belongs_to :user
  belongs_to :specialty
  has_many :working_hours, -> { order(:weekday) }, dependent: :destroy
  has_many :appointments, dependent: :restrict_with_error
  has_many :reviews, dependent: :restrict_with_error

  validates :room, presence: true
  validates :consultation_price, numericality: { greater_than_or_equal_to: 0 }

  delegate :full_name, to: :user

  # Вільні слоти: слоти не зберігаються в БД, а обчислюються з розкладу
  # за вирахуванням зайнятих і тих, що вже минули. Результат: { дата => [час, ...] }
  def free_slots(days = SLOT_DAYS)
    now = Time.current
    last_day = Date.current + (days - 1)
    booked = appointments.not_cancelled
                         .where(starts_at: now..(last_day + 1).in_time_zone)
                         .pluck(:starts_at).map(&:to_i)
    hours = working_hours.index_by(&:weekday)
    result = {}

    (Date.current..last_day).each do |date|
      wh = hours[date.wday]
      next unless wh
      slots = []
      minutes = wh.start_minutes
      while minutes + SLOT_MINUTES <= wh.end_minutes
        time = Time.zone.local(date.year, date.month, date.day, minutes / 60, minutes % 60)
        slots << time if time > now && !booked.include?(time.to_i)
        minutes += SLOT_MINUTES
      end
      result[date] = slots if slots.any?
    end
    result
  end

  # Чи входить час у розклад лікаря (перевірка на сервері, а не лише в інтерфейсі)
  def slot_in_schedule?(time)
    t = time.in_time_zone
    wh = working_hours.detect { |w| w.weekday == t.wday }
    return false unless wh && t.sec.zero?
    minutes = t.hour * 60 + t.min
    minutes >= wh.start_minutes &&
      minutes + SLOT_MINUTES <= wh.end_minutes &&
      (minutes - wh.start_minutes) % SLOT_MINUTES == 0
  end

  # Слот доступний для запису: у розкладі, у майбутньому і ще не зайнятий
  def slot_available?(time)
    time > Time.current && slot_in_schedule?(time) &&
      !appointments.not_cancelled.where(starts_at: time).exists?
  end

  # Кількість слотів лікаря в певний день (для обчислення завантаженості)
  def capacity_on(date)
    wh = working_hours.detect { |w| w.weekday == date.wday }
    wh ? (wh.end_minutes - wh.start_minutes) / SLOT_MINUTES : 0
  end

  def schedule_summary
    working_hours.map { |w| "#{w.weekday_name[0, 2]} #{w.start_time}–#{w.end_time}" }.join(", ")
  end
end
