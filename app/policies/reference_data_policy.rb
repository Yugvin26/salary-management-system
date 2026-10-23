# frozen_string_literal: true

# HR-only CRUD over shared reference data (departments, locations).
class ReferenceDataPolicy < ApplicationPolicy
  def index? = hr?
  def show? = hr?
  def create? = hr?
  def update? = hr?
  def destroy? = hr?

  class Scope < ApplicationPolicy::Scope
    def resolve
      hr? ? scope.where(company_id: user.company_id) : scope.none
    end
  end
end
