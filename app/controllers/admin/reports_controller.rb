# Звіт за період зі статусами, лікарями та спеціальностями + експорт CSV (FR-28, FR-29)
module Admin
  class ReportsController < BaseController
    def show
      @from = parse_date(params[:from]) || Date.current.beginning_of_month
      @to = parse_date(params[:to]) || Date.current
      @from, @to = @to, @from if @to < @from

      scope = Appointment.where(starts_at: @from.in_time_zone...(@to + 1).in_time_zone)
      counts = scope.group(:doctor_profile_id, :status).count

      @rows = DoctorProfile.includes(:user, :specialty).sort_by { |d| d.user.full_name }.map do |doctor|
        by_status = Appointment.statuses.keys.index_with do |status|
          counts.sum { |(doctor_id, st), n| doctor_id == doctor.id && status_key(st) == status ? n : 0 }
        end
        { doctor: doctor, counts: by_status, total: by_status.values.sum }
      end

      @status_totals = Appointment.statuses.keys.index_with { |s| @rows.sum { |r| r[:counts][s] } }
      @specialty_totals = @rows.group_by { |r| r[:doctor].specialty.name }
                               .transform_values { |rows| rows.sum { |r| r[:total] } }
      @total = @status_totals.values.sum
      @revenue = Appointment.payment_paid.where(paid_at: @from.in_time_zone...(@to + 1).in_time_zone).sum(:total_price)

      respond_to do |format|
        format.html
        format.csv do
          send_data csv_data, filename: "report_#{@from}_#{@to}.csv", type: "text/csv; charset=utf-8"
        end
      end
    end

    private

    def status_key(value)
      value.is_a?(Integer) ? Appointment.statuses.key(value) : value.to_s
    end

    def csv_line(fields)
      fields.map { |f| "\"#{f.to_s.gsub('"', '""')}\"" }.join(";")
    end

    def csv_data
      lines = [csv_line(["Лікар", "Спеціальність", "Заплановано", "Завершено", "Скасовано", "Разом"])]
      @rows.each do |r|
        c = r[:counts]
        lines << csv_line([r[:doctor].full_name, r[:doctor].specialty.name,
                           c["scheduled"], c["completed"], c["cancelled"], r[:total]])
      end
      lines << csv_line(["Разом", "", @status_totals["scheduled"], @status_totals["completed"],
                         @status_totals["cancelled"], @total])
      "\uFEFF" + lines.join("\r\n") + "\r\n"   # BOM, щоб Excel коректно відкрив кирилицю
    end
  end
end
