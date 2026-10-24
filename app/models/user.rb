# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable

  belongs_to :company, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true
  has_many :salaries, foreign_key: :employee_id, inverse_of: :employee, dependent: :delete_all
  has_many :password_reset_requests, dependent: :delete_all
  has_one :current_base_salary,
          -> { where(current: true, salary_type: :base) },
          class_name: "Salary",
          foreign_key: :employee_id,
          inverse_of: :employee

  enum :role, { human_resource: 0, employee: 1, super_admin: 2, company_admin: 3 }, validate: true
  enum :work_mode, { remote: "remote", hybrid: "hybrid", in_office: "in_office" }

  scope :with_email, ->(email) { where("lower(email) = ?", email.to_s.strip.downcase) }

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :password, presence: true, confirmation: true, length: { within: 6..128 }, if: :password_required?
  validates :company, presence: true, unless: :super_admin?
  validates :company, absence: true, if: :super_admin?
  validates :employee_id, uniqueness: { scope: :company_id, allow_nil: true }
  validates :employee_id, format: { with: /\AE\d{5,}\z/, message: "must be in format E12345" }, allow_nil: true
  validates :work_mode, inclusion: { in: work_modes.keys }, allow_nil: true
  validate :records_belong_to_company

  with_options if: :employee? do
    validates :employee_id, :job_title, :hire_date, :department, :location, :work_mode, presence: true
    validates :active, inclusion: { in: [ true, false ] }
  end

  before_validation :auto_generate_employee_id, on: :create, if: :employee?

  def name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def name=(value)
    parts = value.to_s.strip.split(/\s+/, 2)
    self.first_name = parts[0]
    self.last_name = parts[1].presence || "-"
  end

  def active_for_authentication?
    super && (super_admin? || company_admin? || active?)
  end

  def records_belong_to_company
    errors.add(:department, "must belong to the company") if department && department.company_id != company_id
    errors.add(:location, "must belong to the company") if location && location.company_id != company_id
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

  def inactive_message
    employee? && !active? ? :archived : super
  end

  private

  def auto_generate_employee_id
    return if employee_id.present?

    last_numeric_id = User.employee.where(company_id: company_id).where.not(employee_id: nil)
                          .pluck(:employee_id)
                          .map { |value| value.delete_prefix("E").to_i }
                          .max.to_i
    self.employee_id = format("E%05d", last_numeric_id + 1)
  end
end
