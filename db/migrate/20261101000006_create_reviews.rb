class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :appointment, null: false, foreign_key: true, index: { unique: true }
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor_profile, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text    :body, null: false
      t.integer :status, null: false, default: 0   # 0 — опубліковано, 1 — приховано модератором
      t.timestamps
    end
  end
end
