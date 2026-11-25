class CartItemsController < ApplicationController
  skip_before_action :require_login

  def create
    service = Service.active.find(params[:service_id])
    session[:cart] = (cart_ids + [service.id]).uniq
    redirect_back fallback_location: services_path, notice: "Послугу «#{service.name}» додано до кошика."
  end

  def destroy
    session[:cart] = cart_ids - [params[:id].to_i]
    redirect_to cart_path, notice: "Послугу видалено з кошика."
  end
end
