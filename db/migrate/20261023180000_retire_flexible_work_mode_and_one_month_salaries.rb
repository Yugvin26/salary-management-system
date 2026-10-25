# frozen_string_literal: true

class RetireFlexibleWorkModeAndOneMonthSalaries < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE users SET work_mode = 'hybrid', updated_at = CURRENT_TIMESTAMP
      WHERE work_mode = 'flexible'
    SQL
    execute <<~SQL.squish
      UPDATE salaries SET current = FALSE, updated_at = CURRENT_TIMESTAMP
      WHERE salary_type IN (1, 2) AND current = TRUE
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
