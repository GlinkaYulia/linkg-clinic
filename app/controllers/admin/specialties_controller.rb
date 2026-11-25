# Довідник спеціальностей (FR-26)
module Admin
  class SpecialtiesController < BaseController
    def index
      @specialties = Specialty.order(:name)
      @specialty = Specialty.new
    end

    def create
      @specialty = Specialty.new(params.require(:specialty).permit(:name))
      if @specialty.save
        redirect_to admin_specialties_path, notice: "Спеціальність додано."
      else
        @specialties = Specialty.order(:name)
        render :index, status: 422
      end
    end

    def destroy
      specialty = Specialty.find(params[:id])
      if specialty.destroy
        redirect_to admin_specialties_path, notice: "Спеціальність видалено."
      else
        redirect_to admin_specialties_path, alert: "Не можна видалити: до спеціальності прив’язані лікарі."
      end
    end
  end
end
