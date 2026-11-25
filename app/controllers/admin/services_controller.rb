# Наповнення каталогу послуг (аналог «наповнення товару»)
module Admin
  class ServicesController < BaseController
    before_action :set_service, only: [:edit, :update]

    def index
      @services = Service.includes(:specialty).order(:name)
    end

    def new
      @service = Service.new
    end

    def create
      @service = Service.new(service_params)
      if @service.save
        redirect_to admin_services_path, notice: "Послугу додано."
      else
        render :new, status: 422
      end
    end

    def edit
    end

    def update
      if @service.update(service_params)
        redirect_to admin_services_path, notice: "Послугу оновлено."
      else
        render :edit, status: 422
      end
    end

    private

    def set_service
      @service = Service.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description, :price, :specialty_id, :active)
    end
  end
end
