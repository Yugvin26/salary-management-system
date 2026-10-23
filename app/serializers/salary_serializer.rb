# frozen_string_literal: true

class SalarySerializer < ApplicationSerializer
  def as_json
    {
      id: record.id,
      employee_id: record.employee_id,
      currency: record.currency,
      salary_type: record.salary_type,
      effective_on: record.effective_on,
      current: record.current,
      amount: record.amount_string,
      formatted_amount: record.pay.format
    }
  end
end
