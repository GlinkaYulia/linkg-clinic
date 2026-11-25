# Форма зворотного зв’язку (доступна всім)
class FeedbackMessagesController < ApplicationController
  skip_before_action :require_login

  def new
    @message = FeedbackMessage.new(name: current_user&.full_name, email: current_user&.email)
  end

  def create
    @message = FeedbackMessage.new(params.require(:feedback_message).permit(:name, :email, :subject, :body))
    @message.user = current_user
    if @message.save
      redirect_to root_path, notice: "Дякуємо! Ваше звернення надіслано, ми зв’яжемося з вами."
    else
      render :new, status: 422
    end
  end
end
