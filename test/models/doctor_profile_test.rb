require "test_helper"

class DoctorProfileTest < ActiveSupport::TestCase
  test "вільні слоти обчислюються з розкладу на 14 днів" do
    doctor = create_doctor
    slots = doctor.free_slots
    assert_operator slots.keys.size, :>=, 13
    assert slots.values.flatten.all? { |t| t > Time.current }
    assert slots.values.flatten.all? { |t| [0, 30].include?(t.min) }
  end

  test "зайнятий слот зникає зі списку вільних" do
    doctor = create_doctor
    slot = next_free_slot(doctor)
    create_appointment(patient: create_user, doctor: doctor, slot: slot)
    assert_not_includes doctor.free_slots.values.flatten.map(&:to_i), slot.to_i
  end

  test "середній рейтинг враховує лише опубліковані відгуки" do
    doctor = create_doctor
    patient = create_user
    first = create_completed_appointment(patient: patient, doctor: doctor, days_ago: 3)
    second = create_completed_appointment(patient: patient, doctor: doctor, days_ago: 4)
    Review.create!(appointment: first, patient: patient, doctor_profile: doctor, rating: 5, body: "Чудовий лікар, дякую!")
    hidden = Review.create!(appointment: second, patient: patient, doctor_profile: doctor, rating: 1, body: "Неприємний досвід візиту.")
    hidden.hidden!
    assert_equal 5, doctor.reviews.published.average(:rating).to_i
  end
end
