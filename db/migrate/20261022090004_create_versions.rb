# frozen_string_literal: true

class CreateVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :versions do |t|
      t.string :whodunnit
      t.string :item_type, null: false
      t.bigint :item_id, null: false
      t.string :event, null: false
      t.jsonb :object
      t.jsonb :object_changes
      t.datetime :created_at
    end

    add_index :versions, %i[item_type item_id]
  end
end
