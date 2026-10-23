# frozen_string_literal: true

module Api
  # Shared CRUD for HR-managed reference data; subclasses define the four hooks below.
  class ReferenceDataController < BaseController
    def index
      authorize model_class
      pagy, records = pagy(policy_scope(model_class).order(*default_order))
      render_data serializer.many(records), meta: pagination_meta(pagy)
    end

    def show
      render_data serializer.one(authorized_record)
    end

    def create
      authorize model_class
      record = model_class.new(permitted_params.merge(company_id: current_company_id))
      if record.save
        render_data serializer.one(record), status: :created
      else
        render_errors(record)
      end
    end

    def update
      record = authorized_record
      if record.update(permitted_params)
        render_data serializer.one(record)
      else
        render_errors(record)
      end
    end

    def destroy
      record = authorized_record
      if record.users.exists?
        render_error("Employees are still assigned", status: :unprocessable_entity)
      else
        record.destroy!
        render_data({ id: record.id, deleted: true })
      end
    end

    private

    def authorized_record
      policy_scope(model_class).find(params[:id]).tap { |record| authorize record }
    end

    def model_class = raise(NotImplementedError)
    def serializer = raise(NotImplementedError)
    def permitted_params = raise(NotImplementedError)
    def default_order = raise(NotImplementedError)
  end
end
