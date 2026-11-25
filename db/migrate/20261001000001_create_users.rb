class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string  :full_name, null: false
      t.string  :email, null: false
      t.string  :phone
      t.date    :birth_date
      t.string  :password_digest, null: false
      t.integer :role, null: false, default: 0   # 0 — пацієнт, 1 — лікар, 2 — адміністратор
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
