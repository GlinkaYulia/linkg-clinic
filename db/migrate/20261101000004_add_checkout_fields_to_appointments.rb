class AddCheckoutFieldsToAppointments < ActiveRecord::Migration[7.1]
  def change
    change_table :appointments do |t|
      t.integer  :delivery_method, null: false, default: 0   # 0 — реєстратура, 1 — email, 2 — пошта
      t.string   :delivery_address
      t.decimal  :delivery_fee, precision: 10, scale: 2, null: false, default: 0
      t.integer  :payment_method, null: false, default: 0    # 0 — готівка, 1 — картка в клініці, 2 — онлайн
      t.integer  :payment_status, null: false, default: 0    # 0 — не оплачено, 1 — оплачено, 2 — повернено
      t.datetime :paid_at
      t.string   :payment_reference
      t.decimal  :total_price, precision: 10, scale: 2, null: false, default: 0
      t.text     :comment
    end
  end
end
