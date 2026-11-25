# Модерація відгуків: приховати або знову опублікувати
module Admin
  class ReviewsController < BaseController
    def index
      @reviews = Review.includes(:patient, doctor_profile: :user).order(created_at: :desc)
    end

    def toggle
      review = Review.find(params[:id])
      review.update!(status: review.published? ? :hidden : :published)
      redirect_to admin_reviews_path, notice: review.published? ? "Відгук опубліковано." : "Відгук приховано."
    end
  end
end
