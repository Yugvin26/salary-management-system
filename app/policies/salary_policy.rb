# frozen_string_literal: true

class SalaryPolicy < ApplicationPolicy
  def index? = same_company_staff? || owns_salary?
  def show? = same_company_staff? || owns_salary?
  def create? = same_company_staff? && !own_salary?
  def update? = same_company_staff? && !own_salary?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if hr?
        scope.joins(:employee).where(users: { company_id: user.company_id })
      elsif employee?
        scope.where(employee_id: user.id)
      else
        scope.none
      end
    end
  end

  private

  def owns_salary?
    employee? && record.employee_id == user.id
  end

  def own_salary?
    user.present? && record.employee_id == user.id
  end

  def same_company_staff?
    hr? && record.employee&.company_id == user.company_id
  end
end
