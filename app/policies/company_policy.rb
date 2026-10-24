# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def index? = super_admin?
  def show? = super_admin?
  def create? = super_admin?
  def update? = super_admin?
  def destroy? = super_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      super_admin? ? scope.all : scope.none
    end
  end
end
