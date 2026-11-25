class CreateDoctorProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :doctor_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :specialty, null: false, foreign_key: true
      t.string :room, null: false
      t.text   :bio
      t.timestamps
    end
  end
end
