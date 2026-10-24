# frozen_string_literal: true

class Company < ApplicationRecord
  has_one :setting, class_name: "Company::Setting", dependent: :destroy
  has_many :users, dependent: :delete_all
  has_many :departments, dependent: :destroy
  has_many :locations, dependent: :destroy

  before_destroy :delete_workforce
  has_many :admins, -> { company_admin }, class_name: "User", inverse_of: :company

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  after_create :ensure_setting

  private

  def ensure_setting
    create_setting! unless setting
  end

  def delete_workforce
    employee_ids = users.select(:id)
    salary_ids = Salary.where(employee_id: employee_ids).select(:id)
    PaperTrail::Version.where(item_type: "Salary", item_id: salary_ids).delete_all
    PasswordResetRequest.where(company_id: id).delete_all
    Salary.where(employee_id: employee_ids).delete_all
  end
end
