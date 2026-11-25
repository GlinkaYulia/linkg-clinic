module Doctor
  class BaseController < ApplicationController
    before_action -> { require_role(:doctor) }
    before_action :set_doctor_profile

    private

    def set_doctor_profile
      @doctor_profile = current_user.doctor_profile
      render "errors/forbidden", status: :forbidden unless @doctor_profile
    end
  end
end
