require "test_helper"

# Повний сценарій пацієнта: кошик → оформлення → онлайн-оплата → скасування
class BookingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @patient = create_user
    @doctor = create_doctor(price: 500)
    @service = create_service(price: 200)
    @slot = next_free_slot(@doctor)
  end

  test "гість може додати послугу до кошика, кошик зберігається після входу" do
    post cart_items_path, params: { service_id: @service.id }
    assert_redirected_to services_path
    log_in(@patient)
    get cart_path
    assert_response :success
    assert_includes response.body, @service.name
  end

  test "оформлення візиту з послугою, доставкою поштою та онлайн-оплатою" do
    log_in(@patient)
    post cart_items_path, params: { service_id: @service.id }

    get new_doctor_appointment_path(@doctor, starts_at: @slot.iso8601)
    assert_response :success

    assert_difference("Appointment.count", 1) do
      post doctor_appointments_path(@doctor), params: {
        starts_at: @slot.iso8601,
        appointment: { delivery_method: "post", delivery_address: "м. Київ, відділення №1", payment_method: "online" }
      }
    end
    appointment = Appointment.order(:id).last
    assert_equal 500 + 200 + 60, appointment.total_price
    assert_redirected_to new_appointment_payment_path(appointment)
    assert_equal [@service.id], appointment.services.pluck(:id)

    # кошик очищено
    get cart_path
    assert_not_includes response.body, @service.name

    # невалідна картка
    post appointment_payment_path(appointment), params: { card_number: "1234 5678 9012 3456", expiry: "12/40", cvv: "123" }
    assert_response 422
    assert appointment.reload.payment_unpaid?

    # валідна тестова картка
    post appointment_payment_path(appointment), params: { card_number: "4242 4242 4242 4242", expiry: "12/40", cvv: "123" }
    assert_redirected_to appointments_path
    assert appointment.reload.payment_paid?
    assert appointment.payment_reference.start_with?("LG-")
  end

  test "другий пацієнт не може забронювати вже зайнятий слот" do
    create_appointment(patient: create_user, doctor: @doctor, slot: @slot)
    log_in(@patient)
    assert_no_difference("Appointment.count") do
      post doctor_appointments_path(@doctor), params: { starts_at: @slot.iso8601, appointment: { delivery_method: "pickup", payment_method: "cash" } }
    end
    assert_response :redirect
  end

  test "пацієнт скасовує візит і слот звільняється" do
    log_in(@patient)
    appointment = create_appointment(patient: @patient, doctor: @doctor, slot: later_slot(@doctor))
    patch cancel_appointment_path(appointment)
    assert_redirected_to appointments_path
    assert appointment.reload.cancelled?
  end

  test "пацієнт не може оплатити чужий візит" do
    other_appointment = create_appointment(patient: create_user, doctor: @doctor, slot: @slot, payment_method: :online)
    log_in(@patient)
    get new_appointment_payment_path(other_appointment)
    assert_response :not_found
  end
end

class ReviewFlowTest < ActionDispatch::IntegrationTest
  test "пацієнт залишає відгук лише після завершеного візиту, один раз" do
    patient = create_user
    doctor = create_doctor
    scheduled = create_appointment(patient: patient, doctor: doctor)
    completed = create_completed_appointment(patient: patient, doctor: doctor)
    log_in(patient)

    get new_appointment_review_path(scheduled)
    assert_response :not_found   # візит ще не завершено

    assert_difference("Review.count", 1) do
      post appointment_review_path(completed), params: { review: { rating: 5, body: "Дуже уважний лікар, дякую!" } }
    end
    assert_redirected_to history_path

    assert_no_difference("Review.count") do
      post appointment_review_path(completed), params: { review: { rating: 1, body: "Спроба залишити другий відгук." } }
    end
  end
end

class FeedbackFlowTest < ActionDispatch::IntegrationTest
  test "гість надсилає звернення, адміністратор бачить і опрацьовує його" do
    assert_difference("FeedbackMessage.count", 1) do
      post contact_path, params: { feedback_message: { name: "Гість", email: "guest@example.com",
                                                       subject: "Питання", body: "Підкажіть режим роботи." } }
    end
    assert_redirected_to root_path

    admin = create_user(role: :admin)
    log_in(admin)
    get admin_feedback_messages_path
    assert_includes response.body, "Питання"
    message = FeedbackMessage.last
    patch mark_answered_admin_feedback_message_path(message)
    assert message.reload.answered?
  end

  test "порожнє звернення відхиляється" do
    assert_no_difference("FeedbackMessage.count") do
      post contact_path, params: { feedback_message: { name: "", email: "bad", subject: "", body: "" } }
    end
    assert_response 422
  end
end
