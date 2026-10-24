# frozen_string_literal: true

class CreatePasswordResetRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :password_reset_requests do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :resolved_by, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.datetime :requested_at, null: false
      t.datetime :resolved_at
      t.timestamps
    end

    add_index :password_reset_requests, :user_id,
              unique: true,
              where: "status = 0",
              name: "index_one_pending_password_reset_per_user"
  end
end
