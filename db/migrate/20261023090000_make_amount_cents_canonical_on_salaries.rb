# frozen_string_literal: true

class MakeAmountCentsCanonicalOnSalaries < ActiveRecord::Migration[8.0]
  def up
    change_column :salaries, :amount_cents, :bigint, null: false
    remove_column :salaries, :amount
  end

  def down
    add_column :salaries, :amount, :decimal, precision: 12, scale: 2
    # Reversal assumes 2-decimal currencies; other exponents cannot be restored from cents alone.
    execute "UPDATE salaries SET amount = amount_cents / 100.0"
    change_column_null :salaries, :amount, false
    change_column :salaries, :amount_cents, :integer, null: false
  end
end
