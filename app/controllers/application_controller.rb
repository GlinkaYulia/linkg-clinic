class ApplicationController < ActionController::Base
  SESSION_TIMEOUT = 30 * 60   # 30 хвилин неактивності

  before_action :check_session_timeout
  before_action :require_login

  helper_method :current_user, :cart_services, :cart_count

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = session[:user_id] && User.enabled.find_by(id: session[:user_id])
  end

  # FR-5: неактивна сесія завершується через 30 хвилин
  def check_session_timeout
    return unless session[:user_id]

    last_seen = session[:last_seen_at]
    if last_seen && Time.current.to_i - last_seen > SESSION_TIMEOUT
      reset_session
      flash[:alert] = "Сесію завершено через неактивність. Увійдіть знову."
      redirect_to login_path
    else
      session[:last_seen_at] = Time.current.to_i
    end
  end

  def require_login
    return if current_user
    redirect_to login_path, alert: "Для доступу до цієї сторінки увійдіть у систему."
  end

  # RBAC на рівні сервера: доступ перевіряється в контролері, а не лише приховуванням кнопок
  def require_role(*roles)
    return if current_user && roles.map(&:to_s).include?(current_user.role)
    render "errors/forbidden", status: :forbidden
  end

  # Кошик послуг зберігається в сесії (працює і для гостей)
  def cart_ids
    Array(session[:cart]).map(&:to_i).uniq
  end

  def cart_services
    @cart_services ||= Service.active.includes(:specialty).where(id: cart_ids).order(:name).to_a
  end

  def cart_count
    cart_services.size
  end

  def render_not_found
    render "errors/not_found", status: :not_found
  end

  def parse_date(value)
    Date.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
