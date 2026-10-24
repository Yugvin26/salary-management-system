# frozen_string_literal: true

class Company
  class SettingPolicy < ApplicationPolicy
    def show? = owns_company?
    def update? = owns_company?

    private

    def owns_company?
      user&.company_admin? && record.company_id == user.company_id
    end
  end
end
