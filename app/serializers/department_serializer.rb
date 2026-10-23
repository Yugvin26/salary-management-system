# frozen_string_literal: true

class DepartmentSerializer < ApplicationSerializer
  def as_json
    { id: record.id, name: record.name }
  end
end
