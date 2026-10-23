# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.integer :role, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :employee_id
      t.string :job_title
      t.date :hire_date
      t.references :department, foreign_key: true
      t.references :location, foreign_key: true
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :users, "lower(email)", unique: true
    add_index :users, :employee_id, unique: true, where: "employee_id IS NOT NULL"
    add_index :users, :role
    add_index :users, :active
    add_index :users, %i[last_name first_name]
  end
end
