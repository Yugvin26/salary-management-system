# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  def as_json
    {
      id: record.id,
      email: record.email,
      role: record.role,
      name: record.name,
      first_name: record.first_name,
      last_name: record.last_name,
      employee_id: record.employee_id,
      job_title: record.job_title,
      work_mode: record.work_mode,
      hire_date: record.hire_date,
      active: record.active,
      company: company_payload,
      department: DepartmentSerializer.one(record.department),
      location: LocationSerializer.one(record.location),
      current_base_salary: SalarySerializer.one(record.current_base_salary)
    }
  end

  private

  def company_payload
    company = record.company
    return unless company

    setting = company.setting
    {
      id: company.id,
      name: company.name,
      setting: setting && {
        primary_color: setting.primary_color,
        accent_color: setting.accent_color,
        background_color: setting.background_color
      }
    }
  end
end
