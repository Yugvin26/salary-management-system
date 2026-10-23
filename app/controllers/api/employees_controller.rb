# frozen_string_literal: true

module Api
  class EmployeesController < BaseController
    def index
      authorize User, :index?
      pagy, employees = pagy(Employees::DirectoryQuery.new(policy_scope(User), directory_params).relation)
      render_data UserSerializer.many(employees), meta: pagination_meta(pagy)
    end

    def show
      employee = find_employee
      authorize employee, :show?
      render_data UserSerializer.one(employee)
    end

    def create
      authorize User, :create?
      employee = User.new(registration_params.merge(active: true, company: current_user.company))
      if employee.save
        render_data UserSerializer.one(employee), status: :created
      else
        render_errors(employee)
      end
    end

    def update
      employee = find_employee
      authorize employee, :update?
      if employee.update(registration_params)
        render_data UserSerializer.one(employee)
      else
        render_errors(employee)
      end
    end

    def archive
      change_active_state(false)
    end

    def unarchive
      change_active_state(true)
    end

    private

    def change_active_state(active)
      employee = find_employee
      authorize employee, :archive?
      employee.update!(active: active)
      render_data UserSerializer.one(employee)
    end

    def find_employee
      directory = User.where(company_id: current_company_id, role: visible_roles)
      directory.includes(:department, :location, :current_base_salary, company: :setting).find(params[:id])
    end

    def directory_params
      query = params.to_unsafe_h
      query[:role] = "all" if current_user.human_resource? && query[:role].blank?
      query
    end

    def visible_roles
      current_user.company_admin? || current_user.human_resource? ? %i[employee human_resource] : [ :employee ]
    end

    def employee_params
      params.require(:employee).permit(*policy(User).permitted_employee_attributes)
    end

    def registration_params
      attrs = employee_params.to_h.symbolize_keys
      attrs[:role] = chosen_role
      return attrs unless attrs[:role] == "human_resource"

      attrs[:job_title] = "HR Partner"
      attrs[:department] = hr_department
      attrs.delete(:department_id)
      attrs
    end

    def hr_department
      current_user.company.departments.where("lower(name) = ?", "hr").first_or_create!(name: "HR")
    end

    def chosen_role
      return "employee" unless current_user.company_admin?

      params.dig(:employee, :role).to_s == "human_resource" ? "human_resource" : "employee"
    end
  end
end
