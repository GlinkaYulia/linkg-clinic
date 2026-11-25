ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Допоміжні методи для створення тестових даних (без fixtures)
module Factories
  PASSWORD = "Password123".freeze

  def create_user(role: :patient, **attrs)
    n = SecureRandom.hex(4)
    User.create!({ full_name: "Тест Користувач #{n}", email: "u#{n}@example.com", phone: "+380500000000",
                   birth_date: "1990-01-01", password: PASSWORD, password_confirmation: PASSWORD,
                   role: role }.merge(attrs))
  end

  # Лікар, який працює щодня 09:00–17:00 (завжди є вільні слоти)
  def create_doctor(price: 500)
    profile = DoctorProfile.create!(user: create_user(role: :doctor),
                                    specialty: Specialty.create!(name: "Спеціальність #{SecureRandom.hex(3)}"),
                                    room: "101", consultation_price: price)
    (0..6).each { |day| profile.working_hours.create!(weekday: day, start_time: "09:00", end_time: "17:00") }
    profile
  end

  def create_service(price: 200, **attrs)
    Service.create!({ name: "Послуга #{SecureRandom.hex(3)}", price: price }.merge(attrs))
  end

  def next_free_slot(doctor)
    doctor.free_slots.values.flatten.first
  end

  # Слот щонайменше через добу — для тестів, що не повинні залежати від часу доби
  def later_slot(doctor)
    doctor.free_slots.values.flatten.find { |time| time > 1.day.from_now }
  end

  def create_appointment(patient:, doctor:, slot: nil, **attrs)
    appointment = patient.appointments.build({ doctor_profile: doctor, starts_at: slot || next_free_slot(doctor) }.merge(attrs))
    appointment.prepare_order([])
    appointment.save!
    appointment
  end

  # Завершений візит у минулому (валідації слота пропускаються)
  def create_completed_appointment(patient:, doctor:, days_ago: 3)
    appointment = patient.appointments.build(doctor_profile: doctor, status: :completed,
                                             starts_at: Time.zone.now.beginning_of_day - days_ago.days + 10.hours)
    appointment.prepare_order([])
    appointment.save!(validate: false)
    appointment
  end
end

class ActiveSupport::TestCase
  include Factories
end

class ActionDispatch::IntegrationTest
  def log_in(user, password: Factories::PASSWORD)
    post login_path, params: { email: user.email, password: password }
  end
end
