# frozen_string_literal: true

module Api
  class DepartmentsController < ReferenceDataController
    private

    def model_class = Department
    def serializer = DepartmentSerializer
    def default_order = [ :name ]
    def permitted_params = params.require(:department).permit(:name)
  end
end
