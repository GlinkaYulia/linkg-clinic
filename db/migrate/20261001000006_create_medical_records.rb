class CreateMedicalRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :medical_records do |t|
      t.references :appointment, null: false, foreign_key: true, index: { unique: true }
      t.text :complaints
      t.text :diagnosis
      t.text :prescription
      t.timestamps
    end
  end
end
