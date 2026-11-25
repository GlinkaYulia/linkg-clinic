class SessionsController < ApplicationController
  skip_before_action :require_login

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.locked?
      # NFR-S6: тимчасове блокування після 5 невдалих спроб
      flash.now[:alert] = "Забагато невдалих спроб входу. Обліковий запис заблоковано до #{helpers.fmt_time(user.locked_until)}."
      render :new, status: 422
    elsif user&.active? && user.authenticate(params[:password].to_s)
      user.reset_failed_attempts!
      cart = session[:cart]          # кошик гостя зберігається після входу
      reset_session
      session[:cart] = cart if cart
      session[:user_id] = user.id
      session[:last_seen_at] = Time.current.to_i
      redirect_to root_path, notice: "Ласкаво просимо, #{user.full_name}!"
    else
      user&.register_failed_attempt!
      flash.now[:alert] = "Невірний email або пароль"
      render :new, status: 422
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Ви вийшли із системи."
  end
end
