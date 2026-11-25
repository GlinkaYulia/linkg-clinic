module ApplicationHelper
  STATUS_BADGES = {
    "scheduled" => ["Заплановано", "primary"],
    "completed" => ["Завершено", "success"],
    "cancelled" => ["Скасовано", "secondary"]
  }.freeze

  def fmt_dt(time)
    time.in_time_zone.strftime("%d.%m.%Y %H:%M")
  end

  def fmt_date(date)
    date.strftime("%d.%m.%Y")
  end

  def fmt_time(time)
    time.in_time_zone.strftime("%H:%M")
  end

  def weekday_name(date)
    WorkingHour::WEEKDAYS[date.wday]
  end

  def status_badge(appointment)
    label, color = STATUS_BADGES[appointment.status]
    label, color = ["Очікує завершення", "warning"] if appointment.scheduled? && appointment.starts_at < Time.current
    content_tag(:span, label, class: "badge text-bg-#{color}")
  end

  # Пункт бічного меню з іконкою; підсвічується, якщо поточна сторінка належить розділу
  def nav_link(label, path, icon = nil)
    active = request.path == path || (path != admin_root_path && path != root_path && request.path.start_with?("#{path}/"))
    link_to path, class: "nav-link#{' active' if active}" do
      safe_join([(icon ? icon_tag(icon) : nil), label].compact, " ")
    end
  end

  # Іконка Bootstrap Icons
  def icon_tag(name, css = nil)
    content_tag(:i, "", class: ["bi", "bi-#{name}", css].compact.join(" "), "aria-hidden": "true")
  end

  SPECIALTY_ICONS = {
    "Терапевт" => "thermometer-half", "Кардіолог" => "heart-pulse", "Невролог" => "activity",
    "Педіатр" => "emoji-smile", "Хірург" => "bandaid"
  }.freeze

  def specialty_icon(name)
    SPECIALTY_ICONS.fetch(name.to_s, "clipboard2-pulse")
  end

  # Фото лікаря: якщо є файл public/doctors/<id>.jpg — показується воно, інакше круг з ініціалами
  def doctor_avatar(doctor, size: 72)
    if File.exist?(Rails.public_path.join("doctors", "#{doctor.id}.jpg"))
      image_tag("/doctors/#{doctor.id}.jpg", alt: doctor.full_name, width: size, height: size, class: "avatar")
    else
      initials = doctor.full_name.split.first(2).map { |word| word[0] }.join
      content_tag(:div, initials, class: "avatar avatar-initials avatar-c#{doctor.specialty_id.to_i % 5}",
                  style: "width:#{size}px;height:#{size}px;font-size:#{(size / 2.6).round}px")
    end
  end

  # Зображення послуги: public/services/<id>.jpg, інакше іконка за спеціальністю
  def service_visual(service)
    if File.exist?(Rails.public_path.join("services", "#{service.id}.jpg"))
      image_tag("/services/#{service.id}.jpg", alt: service.name, class: "service-photo")
    else
      content_tag(:div, icon_tag(specialty_icon(service.specialty&.name)), class: "service-icon")
    end
  end

  # Головне зображення: public/images/hero.jpg (необов’язкове)
  def hero_style
    return unless File.exist?(Rails.public_path.join("images", "hero.jpg"))
    "background-image: linear-gradient(90deg, rgba(36,74,112,.92) 35%, rgba(36,74,112,.35)), url('/images/hero.jpg')"
  end

  def time_options
    (8..20).flat_map { |h| ["%02d:00" % h, "%02d:30" % h] }.select { |t| t <= "20:00" }
  end

  def weekday_options
    [1, 2, 3, 4, 5, 6, 0].map { |d| [WorkingHour::WEEKDAYS[d], d] }
  end

  # Грошова сума у форматі «1 250,00 грн»
  def fmt_money(amount)
    whole, fraction = format("%.2f", amount.to_f).split(".")
    whole = whole.reverse.scan(/\d{1,3}/).join(" ").reverse
    "#{whole},#{fraction} грн"
  end

  # Рейтинг у вигляді зірок: ★★★★☆
  def stars(rating)
    full = rating.to_f.round.clamp(0, 5)
    ("★" * full) + ("☆" * (5 - full))
  end

  # «Петренко Марія Іванівна» -> «Марія П.»
  def short_name(full_name)
    parts = full_name.to_s.split
    return full_name.to_s if parts.size < 2
    "#{parts[1]} #{parts[0][0]}."
  end

  def payment_badge(appointment)
    color = { "paid" => "success", "unpaid" => "warning", "refunded" => "secondary" }[appointment.payment_status]
    content_tag(:span, appointment.payment_status_label, class: "badge text-bg-#{color}")
  end
end
