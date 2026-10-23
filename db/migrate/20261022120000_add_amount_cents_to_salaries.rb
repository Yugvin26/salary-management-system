# frozen_string_literal: true

class AddAmountCentsToSalaries < ActiveRecord::Migration[8.0]
  def up
    add_column :salaries, :amount_cents, :integer
    execute "UPDATE salaries SET amount_cents = ROUND(amount * 100)"
    change_column_null :salaries, :amount_cents, false
  end

  def down
    remove_column :salaries, :amount_cents
  end
end
