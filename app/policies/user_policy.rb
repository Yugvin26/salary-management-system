# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  EMPLOYEE_ATTRIBUTES = %i[
    email password password_confirmation name first_name last_name employee_id
    job_title work_mode hire_date department_id location_id active
  ].freeze

  def index? = hr?
  def show? = hr? || own_record?
  def create? = hr?
  def update? = hr?
  def archive? = hr?
  def assign_hr_role? = user&.company_admin? || false

  def permitted_attributes
    assign_hr_role? ? EMPLOYEE_ATTRIBUTES + [ :role ] : EMPLOYEE_ATTRIBUTES
  end

  def permitted_employee_attributes = EMPLOYEE_ATTRIBUTES

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.company_admin? || user&.human_resource?
        scope.where(company_id: user.company_id, role: [ User.roles[:employee], User.roles[:human_resource] ])
      elsif employee?
        scope.where(id: user.id)
      else
        scope.none
      end
    end
  end

  private

  def own_record?
    user.present? && record.respond_to?(:id) && user.id == record.id
  end
end
