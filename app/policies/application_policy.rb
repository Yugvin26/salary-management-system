# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false
  def show? = false
  def create? = false
  def update? = false
  def destroy? = false

  private

  def hr? = user&.human_resource? || user&.company_admin? || false
  def employee? = user&.employee? || false
  def super_admin? = user&.super_admin? || false

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope

    def hr? = user&.human_resource? || user&.company_admin? || false
    def employee? = user&.employee? || false
    def super_admin? = user&.super_admin? || false
  end
end
