class CreateFeedbackMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :feedback_messages do |t|
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.text   :body, null: false
      t.integer :status, null: false, default: 0   # 0 — нове, 1 — опрацьовано
      t.timestamps
    end
  end
end
