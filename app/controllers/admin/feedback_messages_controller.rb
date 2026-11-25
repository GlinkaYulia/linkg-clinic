# Вхідні звернення з форми зворотного зв’язку
module Admin
  class FeedbackMessagesController < BaseController
    def index
      @messages = FeedbackMessage.order(:status, created_at: :desc)
    end

    def mark_answered
      FeedbackMessage.find(params[:id]).answered!
      redirect_to admin_feedback_messages_path, notice: "Звернення позначено як опрацьоване."
    end
  end
end
