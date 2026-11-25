require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @patient = create_user
    @doctor = create_doctor
    @appointment = create_completed_appointment(patient: @patient, doctor: @doctor)
  end

  test "коректний відгук зберігається" do
    review = Review.new(appointment: @appointment, patient: @patient, doctor_profile: @doctor, rating: 4, body: "Все пройшло добре, дякую.")
    assert review.valid?
  end

  test "оцінка має бути від 1 до 5" do
    review = Review.new(appointment: @appointment, patient: @patient, doctor_profile: @doctor, rating: 6, body: "Занадто висока оцінка.")
    assert_not review.valid?
  end

  test "занадто короткий відгук недопустимий" do
    review = Review.new(appointment: @appointment, patient: @patient, doctor_profile: @doctor, rating: 5, body: "Ок")
    assert_not review.valid?
  end

  test "на один візит — один відгук" do
    Review.create!(appointment: @appointment, patient: @patient, doctor_profile: @doctor, rating: 5, body: "Перший відгук про візит.")
    second = Review.new(appointment: @appointment, patient: @patient, doctor_profile: @doctor, rating: 3, body: "Другий відгук про візит.")
    assert_not second.valid?
  end
end
