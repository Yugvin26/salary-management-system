# frozen_string_literal: true

class PasswordResetRequest < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :resolved_by, class_name: "User", optional: true

  enum :status, { pending: 0, completed: 1 }, validate: true

  validates :requested_at, presence: true
  validate :one_pending_request, if: :pending?

  private

  def one_pending_request
    return unless self.class.pending.where(user_id: user_id).where.not(id: id).exists?

    errors.add(:user, "already has a pending request")
  end
end
