# frozen_string_literal: true

class Department < ApplicationRecord
  belongs_to :company
  has_many :users, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }
end
