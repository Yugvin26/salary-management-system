# frozen_string_literal: true

class Company
  class Setting < ApplicationRecord
    self.table_name = "company_settings"

    HEX_COLOR = /\A#[0-9A-Fa-f]{6}\z/

    belongs_to :company

    validates :primary_color, :accent_color, :background_color, presence: true, format: { with: HEX_COLOR }
  end
end
