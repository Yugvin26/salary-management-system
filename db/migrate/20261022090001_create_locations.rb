# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :country, null: false
      t.timestamps
    end

    add_index :locations, :country
  end
end
