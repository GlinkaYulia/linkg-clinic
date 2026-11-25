# Каталог послуг: фільтр за спеціальністю, пошук і сортування за ціною (публічна сторінка)
class ServicesController < ApplicationController
  skip_before_action :require_login

  def index
    @specialties = Specialty.order(:name)
    services = Service.active.includes(:specialty)
    services = services.where(specialty_id: params[:specialty_id]) if params[:specialty_id].present?
    services = case params[:sort]
               when "price_asc" then services.order(:price, :name)
               when "price_desc" then services.order(price: :desc, name: :asc)
               else services.order(:name)
               end
    @services = services.to_a
    if params[:q].present?
      query = params[:q].to_s.strip.downcase
      @services = @services.select { |s| s.name.downcase.include?(query) || s.description.to_s.downcase.include?(query) }
    end
    @in_cart = cart_ids
  end
end
