# frozen_string_literal: true

class AddWorkModeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :work_mode, :string
    add_index :users, :work_mode
  end
end
