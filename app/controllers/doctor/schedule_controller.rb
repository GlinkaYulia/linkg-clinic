# Розклад лікаря на день або тиждень (FR-15)
module Doctor
  class ScheduleController < BaseController
    def index
      @range = params[:range] == "week" ? "week" : "day"
      @date = parse_date(params[:date]) || Date.current
      from = @date.in_time_zone
      to = (@date + (@range == "week" ? 7 : 1)).in_time_zone
      @appointments = @doctor_profile.appointments.scheduled
                                     .where(starts_at: from...to).includes(:patient).order(:starts_at)
    end
  end
end
