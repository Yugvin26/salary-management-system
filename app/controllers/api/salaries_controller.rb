# frozen_string_literal: true

module Api
  class SalariesController < BaseController
    def index
      employee = staff_member
      authorize Salary.new(employee_id: employee.id), :index?
      pagy, salaries = pagy(policy_scope(Salary).where(employee_id: employee.id).order(effective_on: :desc, id: :desc))
      render_data SalarySerializer.many(salaries), meta: pagination_meta(pagy).merge(monthly_payout: Salary.monthly_payout(employee))
    end

    def create
      employee = staff_member
      if (current_user.company_admin? || current_user.human_resource?) && employee.id == current_user.id
        skip_authorization
        render_error("You cannot change your own salary", status: :forbidden)
        return
      end
      authorize Salary.new(employee_id: employee.id), :create?
      salary = employee.salaries.new(salary_params)
      if salary.save
        render_data SalarySerializer.one(salary), status: :created
      else
        render_errors(salary)
      end
    rescue ActiveRecord::RecordNotUnique
      render_error("already exists for this salary type", status: :unprocessable_entity, field: :current)
    end

    private

    def staff_member
      roles = current_user.company_admin? || current_user.human_resource? ? %i[employee human_resource] : [ :employee ]
      User.where(company_id: current_company_id, role: roles).find(params[:employee_id])
    end

    def salary_params
      permitted = params.require(:salary).permit(:amount, :currency, :salary_type, :effective_on, :current)
      permitted[:current] = permitted.key?(:current) ? ActiveModel::Type::Boolean.new.cast(permitted[:current]) : true
      permitted
    end
  end
end
