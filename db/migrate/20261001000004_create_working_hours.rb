class CreateWorkingHours < ActiveRecord::Migration[7.1]
  def change
    create_table :working_hours do |t|
      t.references :doctor_profile, null: false, foreign_key: true
      t.integer :weekday, null: false      # 0 — неділя ... 6 — субота
      t.string  :start_time, null: false   # "09:00"
      t.string  :end_time, null: false     # "16:00"
      t.timestamps
    end
    add_index :working_hours, [:doctor_profile_id, :weekday], unique: true
  end
end
