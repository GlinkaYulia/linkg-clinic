# Кошик послуг
class CartsController < ApplicationController
  skip_before_action :require_login

  def show
    @services = cart_services
    @total = @services.sum(&:price)
  end

  def destroy
    session[:cart] = []
    redirect_to cart_path, notice: "Кошик очищено."
  end
end
