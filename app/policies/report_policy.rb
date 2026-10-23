# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def dashboard? = hr?
  def departments? = hr?
  def job_titles? = hr?
  def countries? = hr?
  def export? = hr?
end
