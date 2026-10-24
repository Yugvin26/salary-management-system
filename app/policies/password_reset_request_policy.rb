# frozen_string_literal: true

class PasswordResetRequestPolicy < ApplicationPolicy
  def index? = hr?
  def create? = employee? && record.user_id == user.id
  def update? = hr? && record.pending? && record.company_id == user.company_id

  class Scope < ApplicationPolicy::Scope
    def resolve
      hr? ? scope.where(company_id: user.company_id) : scope.none
    end
  end
end
