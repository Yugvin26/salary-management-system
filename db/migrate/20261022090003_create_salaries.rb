# frozen_string_literal: true

class CreateSalaries < ActiveRecord::Migration[8.0]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false, limit: 3
      t.integer :salary_type, null: false
      t.date :effective_on, null: false
      t.boolean :current, null: false, default: false
      t.timestamps
    end

    add_index :salaries, %i[employee_id salary_type],
              unique: true,
              where: "current = true",
              name: "index_salaries_one_current_per_type"
    add_index :salaries, %i[salary_type current]
    add_index :salaries, :effective_on
  end
end
