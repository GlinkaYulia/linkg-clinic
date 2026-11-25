# Список лікарів з фільтром, пошуком і рейтингом; вільні слоти та відгуки. Доступно й гостям.
class DoctorsController < ApplicationController
  skip_before_action :require_login

  def index
    @specialties = Specialty.order(:name)
    doctors = visible_doctors.includes(:user, :specialty).order("users.full_name")
    doctors = doctors.where(specialty_id: params[:specialty_id]) if params[:specialty_id].present?
    @doctors = doctors.to_a
    if params[:q].present?
      query = params[:q].to_s.strip.downcase
      @doctors = @doctors.select { |d| d.full_name.downcase.include?(query) }
    end
    @ratings = Review.published.group(:doctor_profile_id).average(:rating)
    @review_counts = Review.published.group(:doctor_profile_id).count
  end

  def show
    @doctor = visible_doctors.includes(:user, :specialty).find(params[:id])
    @slots = @doctor.free_slots
    @reviews = @doctor.reviews.published.includes(:patient).order(created_at: :desc).limit(20)
    @average = @doctor.reviews.published.average(:rating)
    @reviews_count = @doctor.reviews.published.count
  end

  private

  def visible_doctors
    DoctorProfile.joins(:user).where(users: { active: true })
  end
end
