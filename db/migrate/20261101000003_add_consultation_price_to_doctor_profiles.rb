class AddConsultationPriceToDoctorProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :doctor_profiles, :consultation_price, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end
