class CreateServices < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|
      t.string  :name, null: false
      t.text    :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.references :specialty, null: true, foreign_key: true
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :services, :name, unique: true
  end
end
