class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor_profile, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer  :status, null: false, default: 0   # 0 — scheduled, 1 — completed, 2 — cancelled
      t.datetime :cancelled_at
      t.timestamps
    end
    add_index :appointments, :starts_at
    add_index :appointments, :status
    # Захист від подвійного бронювання: один слот лікаря може бути зайнятий лише раз (скасовані візити не враховуються)
    add_index :appointments, [:doctor_profile_id, :starts_at],
              unique: true, where: "status <> 2", name: "index_appointments_unique_active_slot"
  end
end
