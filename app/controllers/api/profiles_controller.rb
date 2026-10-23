# frozen_string_literal: true

module Api
  class ProfilesController < BaseController
    def show
      authorize current_user, :show?
      salaries = current_user.salaries.order(effective_on: :desc, id: :desc)
      render_data UserSerializer.one(current_user).merge(
        salaries: SalarySerializer.many(salaries),
        monthly_payout: Salary.monthly_payout(current_user)
      )
    end
  end
end
