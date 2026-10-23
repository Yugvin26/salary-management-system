# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable

  enum :role, { human_resource: 0, employee: 1 }, validate: true

  scope :with_email, ->(email) { where("lower(email) = ?", email.to_s.strip.downcase) }

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, presence: true, confirmation: true, length: { within: 6..128 }, if: :password_required?

  def name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def name=(value)
    parts = value.to_s.strip.split(/\s+/, 2)
    self.first_name = parts[0]
    self.last_name = parts[1].presence || "-"
  end

  def active_for_authentication?
    super && active?
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

  def inactive_message
    employee? && !active? ? :archived : super
  end
end
