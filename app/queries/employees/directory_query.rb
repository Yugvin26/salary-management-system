# frozen_string_literal: true

module Employees
  class DirectoryQuery
    MAX_SEARCH_LENGTH = 100
    SEARCH_SQL = <<~'SQL'.squish.freeze
      users.first_name ILIKE :q ESCAPE '\'
      OR users.last_name ILIKE :q ESCAPE '\'
      OR CONCAT(users.first_name, ' ', users.last_name) ILIKE :q ESCAPE '\'
      OR users.email ILIKE :q ESCAPE '\'
      OR users.employee_id ILIKE :q ESCAPE '\'
    SQL

    def initialize(relation, params)
      @relation = relation
      @params = params
    end

    def relation
      filtered.includes(:department, :location, :current_base_salary, company: :setting).order(:last_name, :first_name, :id)
    end

    def filtered
      scope = filter_role(@relation)
      scope = filter_status(scope)
      scope = filter_search(scope)
      scope = filter_department(scope)
      filter_country(scope)
    end

    private

    def filter_role(scope)
      case @params[:role].to_s
      when "human_resource" then scope.human_resource
      when "all" then scope.where(role: [ User.roles[:employee], User.roles[:human_resource] ])
      else scope.employee
      end
    end

    def filter_status(scope)
      case @params[:status].presence || "active"
      when "archived" then scope.where(active: false)
      when "all" then scope
      else scope.where(active: true)
      end
    end

    def filter_search(scope)
      term = @params[:q].to_s.strip.first(MAX_SEARCH_LENGTH)
      return scope if term.blank?

      # Escape user-typed % and _ so they match literally instead of acting as wildcards.
      scope.where(SEARCH_SQL, q: "%#{ActiveRecord::Base.sanitize_sql_like(term)}%")
    end

    def filter_department(scope)
      return scope if @params[:department_id].blank?

      scope.where(department_id: @params[:department_id])
    end

    def filter_country(scope)
      return scope if @params[:country].blank?

      scope.joins(:location).where(locations: { country: @params[:country] })
    end
  end
end
