# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :company
  has_many :users, dependent: :restrict_with_error

  validates :name, :city, :country, presence: true
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }
end
