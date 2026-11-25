require "test_helper"

# Перевірка рольової моделі доступу (RBAC) на рівні сервера
class AuthorizationTest < ActionDispatch::IntegrationTest
  test "гість перенаправляється на сторінку входу" do
    get appointments_path
    assert_redirected_to login_path
  end

  test "публічні сторінки доступні гостю" do
    [root_path, doctors_path, services_path, cart_path, contact_path, login_path, register_path].each do |path|
      get path
      assert_response :success, "#{path} має бути доступна гостю"
    end
  end

  test "пацієнт не має доступу до адмін-панелі та кабінету лікаря" do
    log_in(create_user)
    get admin_root_path
    assert_response :forbidden
    get doctor_schedule_path
    assert_response :forbidden
  end

  test "лікар не бачить пацієнтів, які ніколи не були записані до нього" do
    doctor = create_doctor
    log_in(doctor.user)
    stranger = create_user
    get doctor_patient_path(stranger)
    assert_response :forbidden

    create_appointment(patient: stranger, doctor: doctor)
    get doctor_patient_path(stranger)
    assert_response :success
  end

  test "після 5 невдалих спроб вхід блокується навіть з правильним паролем" do
    user = create_user
    5.times { post login_path, params: { email: user.email, password: "wrong" } }
    post login_path, params: { email: user.email, password: Factories::PASSWORD }
    assert_response 422
    assert_includes response.body, "заблоковано"
  end

  test "деактивований користувач не може увійти" do
    user = create_user(active: false)
    post login_path, params: { email: user.email, password: Factories::PASSWORD }
    assert_response 422
  end

  test "адміністратор приховує відгук, і він зникає зі сторінки лікаря" do
    doctor = create_doctor
    patient = create_user
    appointment = create_completed_appointment(patient: patient, doctor: doctor)
    review = Review.create!(appointment: appointment, patient: patient, doctor_profile: doctor,
                            rating: 5, body: "Унікальний текст відгуку для перевірки.")
    get doctor_path(doctor)
    assert_includes response.body, "Унікальний текст відгуку"

    log_in(create_user(role: :admin))
    patch toggle_admin_review_path(review)
    assert review.reload.hidden?

    delete logout_path
    get doctor_path(doctor)
    assert_not_includes response.body, "Унікальний текст відгуку"
  end

  test "адміністратор створює послугу в каталозі" do
    log_in(create_user(role: :admin))
    assert_difference("Service.count", 1) do
      post admin_services_path, params: { service: { name: "Тестова послуга", price: "321.50", active: "1" } }
    end
    get services_path
    assert_includes response.body, "Тестова послуга"
  end
end
