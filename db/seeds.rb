# Початкові дані для демонстрації
specialties = %w[Терапевт Кардіолог Невролог Педіатр Хірург].index_with do |name|
  Specialty.find_or_create_by!(name: name)
end

def create_user(attrs)
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.assign_attributes(attrs)
  end
end

create_user(full_name: "Адміністратор Системи", email: "admin@linkg.clinic", phone: "+380501110000",
            role: :admin, password: "Admin12345", password_confirmation: "Admin12345")

doctors_data = [
  { name: "Іваненко Олена Петрівна", email: "ivanenko@linkg.clinic", spec: "Терапевт", room: "101", price: 500,
    bio: "Лікар-терапевт вищої категорії. Стаж понад 15 років.", days: [1, 2, 3, 4, 5], from: "09:00", to: "16:00" },
  { name: "Коваль Андрій Миколайович", email: "koval@linkg.clinic", spec: "Кардіолог", room: "205", price: 800,
    bio: "Діагностика та лікування серцево-судинних захворювань.", days: [1, 3, 5], from: "10:00", to: "15:00" },
  { name: "Мельник Ірина Василівна", email: "melnyk@linkg.clinic", spec: "Невролог", room: "214", price: 700,
    bio: "Лікування головного болю, остеохондрозу, порушень сну.", days: [2, 4], from: "12:00", to: "18:00" },
  { name: "Шевчук Тарас Олегович", email: "shevchuk@linkg.clinic", spec: "Педіатр", room: "108", price: 450,
    bio: "Дитячий лікар, профілактичні огляди та вакцинація.", days: [1, 2, 3, 4, 5], from: "08:00", to: "14:00" }
]

profiles = doctors_data.map do |d|
  user = create_user(full_name: d[:name], email: d[:email], phone: "+38050#{rand(1_000_000..9_999_999)}",
                     role: :doctor, password: "Doctor123", password_confirmation: "Doctor123")
  profile = DoctorProfile.find_or_create_by!(user: user) do |p|
    p.specialty = specialties[d[:spec]]
    p.room = d[:room]
    p.bio = d[:bio]
  end
  profile.update!(consultation_price: d[:price])
  d[:days].each do |day|
    profile.working_hours.find_or_create_by!(weekday: day) { |w| w.start_time = d[:from]; w.end_time = d[:to] }
  end
  profile
end

# Каталог послуг
services_data = [
  ["Загальний аналіз крові", "Розгорнутий аналіз крові з лейкоцитарною формулою.", 250, "Терапевт"],
  ["Біохімічний аналіз крові", "Глюкоза, холестерин, печінкові проби, креатинін.", 480, "Терапевт"],
  ["Загальний аналіз сечі", "Клінічний аналіз сечі.", 150, "Терапевт"],
  ["Електрокардіографія (ЕКГ)", "ЕКГ у 12 відведеннях із розшифруванням.", 350, "Кардіолог"],
  ["Холтерівське моніторування", "Добовий моніторинг ритму серця.", 1200, "Кардіолог"],
  ["УЗД серця", "Ехокардіографія з допплерографією.", 900, "Кардіолог"],
  ["Електроенцефалографія (ЕЕГ)", "Дослідження біоелектричної активності мозку.", 1100, "Невролог"],
  ["Масаж спини", "Лікувальний масаж (30 хв).", 400, "Невролог"],
  ["Профілактичний огляд дитини", "Огляд, вимірювання зросту і ваги, рекомендації.", 300, "Педіатр"],
  ["Вакцинація (без вартості вакцини)", "Введення вакцини за календарем щеплень.", 200, "Педіатр"],
  ["Перев’язка", "Обробка рани, накладання пов’язки.", 180, "Хірург"],
  ["Медична довідка", "Довідка про стан здоров’я.", 120, nil]
]
services_data.each do |name, description, price, spec|
  service = Service.find_or_initialize_by(name: name)
  service.assign_attributes(description: description, price: price, specialty: (spec && specialties[spec]), active: true)
  service.save!
end

patient = create_user(full_name: "Петренко Марія Іванівна", email: "patient@linkg.clinic", phone: "+380671234567",
                      birth_date: "1995-04-12", role: :patient, password: "Patient123", password_confirmation: "Patient123")
other = create_user(full_name: "Бондар Олег Сергійович", email: "bondar@linkg.clinic", phone: "+380931112233",
                    birth_date: "1988-09-30", role: :patient, password: "Patient123", password_confirmation: "Patient123")

if Appointment.none?
  therapist, cardiologist = profiles[0], profiles[1]
  blood = Service.find_by!(name: "Загальний аналіз крові")
  ecg = Service.find_by!(name: "Електрокардіографія (ЕКГ)")

  # Минулі завершені візити з медичними записами, оплатою та відгуками
  past = [
    [patient, therapist, 21, 10, [blood], "Кашель, підвищена температура 37,8 протягом трьох днів.",
     "Гострий бронхіт", "Амброксол 30 мг 3 рази на день, рясне пиття, повторний огляд через 7 днів.",
     5, "Уважна лікарка, все детально пояснила і призначила ефективне лікування. Дякую!"],
    [patient, cardiologist, 10, 11, [ecg], "Періодичне підвищення артеріального тиску, головний біль.",
     "Артеріальна гіпертензія I ступеня", "Контроль тиску двічі на день, обмеження солі, ЕКГ.",
     4, "Професійний підхід, але довелося трохи почекати біля кабінету."],
    [other, therapist, 5, 9, [], "Загальна слабкість, біль у горлі.",
     "Гострий фарингіт", "Полоскання горла розчином фурациліну, тепле пиття.", nil, nil]
  ]
  past.each do |pat, doc, days_ago, hour, services, complaints, diagnosis, prescription, rating, review_text|
    time = (Time.zone.now.beginning_of_day - days_ago.days) + hour.hours
    appt = Appointment.new(patient: pat, doctor_profile: doc, starts_at: time, status: :completed,
                           payment_method: :card_clinic)
    appt.prepare_order(services)
    appt.payment_status = :paid
    appt.paid_at = time
    appt.payment_reference = "LG-#{SecureRandom.hex(4).upcase}"
    appt.save!(validate: false)
    MedicalRecord.create!(appointment: appt, complaints: complaints, diagnosis: diagnosis, prescription: prescription)
    Review.create!(appointment: appt, patient: pat, doctor_profile: doc, rating: rating, body: review_text) if rating
  end

  # Майбутні візити (слоти беруться з розкладу лікаря)
  slots = therapist.free_slots.values.flatten
  [[patient, 2, [blood], :online], [other, 3, [], :cash], [other, 6, [], :card_clinic]].each do |pat, idx, services, method|
    next unless slots[idx]
    appt = pat.appointments.build(doctor_profile: therapist, starts_at: slots[idx], payment_method: method)
    appt.prepare_order(services)
    appt.save!
  end
end

if FeedbackMessage.none?
  FeedbackMessage.create!(name: "Петренко Марія", email: "patient@linkg.clinic", subject: "Графік роботи лабораторії",
                          body: "Доброго дня! Підкажіть, будь ласка, до котрої години працює лабораторія по суботах?",
                          user: patient)
end

puts "Seed завершено: користувачів — #{User.count}, лікарів — #{DoctorProfile.count}, послуг — #{Service.count}, " \
     "візитів — #{Appointment.count}, відгуків — #{Review.count}"
