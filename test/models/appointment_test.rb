require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  setup do
    @patient = create_user
    @doctor = create_doctor(price: 500)
    @slot = next_free_slot(@doctor)
  end

  test "візит на вільний слот створюється" do
    appointment = @patient.appointments.build(doctor_profile: @doctor, starts_at: @slot)
    assert appointment.valid?, appointment.errors.full_messages.to_sentence
  end

  test "не можна записатися на час у минулому" do
    appointment = @patient.appointments.build(doctor_profile: @doctor, starts_at: 1.hour.ago.change(sec: 0))
    assert_not appointment.valid?
  end

  test "не можна записатися поза розкладом лікаря" do
    midnight = (Date.current + 1).in_time_zone + 3.hours
    appointment = @patient.appointments.build(doctor_profile: @doctor, starts_at: midnight)
    assert_not appointment.valid?
    assert_includes appointment.errors.full_messages.join, "розкладу"
  end

  test "зайнятий слот не можна забронювати вдруге" do
    create_appointment(patient: @patient, doctor: @doctor, slot: @slot)
    other = create_user
    second = other.appointments.build(doctor_profile: @doctor, starts_at: @slot)
    assert_not second.valid?
    assert_includes second.errors.full_messages.join, "зайнятий"
  end

  test "унікальний індекс БД блокує подвійне бронювання" do
    create_appointment(patient: @patient, doctor: @doctor, slot: @slot)
    other = create_user
    duplicate = other.appointments.build(doctor_profile: @doctor, starts_at: @slot)
    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end

  test "скасований слот знову доступний" do
    appointment = create_appointment(patient: @patient, doctor: @doctor, slot: @slot)
    appointment.cancel!
    assert @doctor.slot_available?(@slot)
  end

  test "пацієнт не може мати два візити на той самий час" do
    create_appointment(patient: @patient, doctor: @doctor, slot: @slot)
    other_doctor = create_doctor
    second = @patient.appointments.build(doctor_profile: other_doctor, starts_at: @slot)
    assert_not second.valid?
    assert_includes second.errors.full_messages.join, "уже є візит"
  end

  test "скасувати можна не пізніше ніж за 2 години" do
    far = create_appointment(patient: @patient, doctor: @doctor, slot: @slot)
    far.update_columns(starts_at: 3.hours.from_now)
    assert far.cancellable?
    far.update_columns(starts_at: 1.hour.from_now)
    assert_not far.cancellable?
  end

  test "сума: консультація + послуги + доставка поштою" do
    services = [create_service(price: 200), create_service(price: 150)]
    appointment = @patient.appointments.build(doctor_profile: @doctor, starts_at: @slot,
                                              delivery_method: :post, delivery_address: "Київ, НП №1")
    appointment.prepare_order(services)
    assert_equal 500 + 200 + 150 + 60, appointment.total_price
    assert_equal 2, appointment.appointment_services.size
    assert appointment.save
  end

  test "для доставки поштою потрібна адреса" do
    appointment = @patient.appointments.build(doctor_profile: @doctor, starts_at: @slot, delivery_method: :post)
    appointment.prepare_order([])
    assert_not appointment.valid?
    assert appointment.errors[:delivery_address].any?
  end

  test "скасування оплаченого візиту повертає кошти" do
    appointment = create_appointment(patient: @patient, doctor: @doctor, slot: @slot, payment_method: :online)
    appointment.mark_paid!
    assert appointment.payment_paid?
    appointment.cancel!
    assert appointment.reload.payment_refunded?
    assert appointment.cancelled?
  end
end
