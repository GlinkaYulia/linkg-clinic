class CreateAppointmentServices < ActiveRecord::Migration[7.1]
  def change
    create_table :appointment_services do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false   # ціна на момент оформлення
      t.timestamps
    end
    add_index :appointment_services, [:appointment_id, :service_id], unique: true
  end
end
