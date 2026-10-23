# frozen_string_literal: true

class Salary < ApplicationRecord
  has_paper_trail

  belongs_to :employee, class_name: "User", inverse_of: :salaries

  monetize :amount_cents, as: :pay, with_model_currency: :currency

  enum :salary_type, { base: 0, bonus: 1, commission: 2 }, validate: true

  scope :current_base, -> { where(current: true, salary_type: :base) }

  validates :amount, numericality: { greater_than: 0 }
  before_validation :convert_amount_input
  validates :currency, format: { with: /\A[A-Z]{3}\z/, message: "must be three uppercase letters" }
  validates :effective_on, presence: true
  validates :current, inclusion: { in: [ true, false ] }
  validate :employee_can_receive_salary
  validate :currency_matches_existing_employee_currency
  before_validation :record_one_month_pay_as_history

  before_save :retire_previous_current, if: :current?

  # Plain decimal string using the currency's own exponent (JPY 0, USD 2, KWD 3).
  def self.amount_string(cents, currency)
    money = Money.new(cents, currency)
    format("%.#{money.currency.exponent}f", money.amount)
  end

  def self.money_fields(cents, currency, key)
    {
      key => amount_string(cents, currency),
      :"formatted_#{key}" => Money.new(cents, currency).format
    }
  end

  # Major-unit input; amount_cents is the only stored value.
  def amount=(value)
    @amount_input = value
    convert_amount_input
  end

  def amount
    return BigDecimal(@amount_input.to_s, exception: false) if amount_cents.nil? && !@amount_input.nil?

    pay&.amount
  end

  def amount_string
    self.class.amount_string(amount_cents, currency)
  end

  # Base is a yearly amount. This month pays one twelfth of the current base,
  # plus bonus and commission lines whose effective date falls in the month.
  def self.monthly_payout(employee, on: Date.current)
    lines = employee.salaries
    base = lines.current_base.first
    currency = base&.currency || lines.order(created_at: :desc).pick(:currency)
    month = on.strftime("%Y-%m")
    return { month: month, currency: nil } if currency.blank?

    parts = monthly_payout_parts(lines, base, currency, on)
    {
      month: month,
      currency: currency,
      base_annual: base && amount_string(base.amount_cents, currency),
      formatted_base_annual: base && Money.new(base.amount_cents, currency).format,
      **money_fields(parts.fetch(:base_cents), currency, :base_monthly),
      **money_fields(parts.fetch(:bonus_cents), currency, :bonus),
      **money_fields(parts.fetch(:commission_cents), currency, :commission),
      **money_fields(parts.fetch(:total_cents), currency, :total)
    }
  end

  def self.monthly_payout_parts(lines, base, currency, on)
    extras = lines.where(salary_type: %i[bonus commission], effective_on: on.all_month)
    bonus_cents = extras.bonus.sum(:amount_cents)
    commission_cents = extras.commission.sum(:amount_cents)
    base_cents = base ? (Money.new(base.amount_cents, currency) / 12).cents : 0
    {
      base_cents: base_cents,
      bonus_cents: bonus_cents,
      commission_cents: commission_cents,
      total_cents: base_cents + bonus_cents + commission_cents
    }
  end
  private_class_method :monthly_payout_parts

  private

  def convert_amount_input
    return if @amount_input.nil? || currency.blank?

    decimal = BigDecimal(@amount_input.to_s, exception: false)
    self.amount_cents = decimal && Money.from_amount(decimal, currency).cents
  rescue Money::Currency::UnknownCurrency
    self.amount_cents = nil
  end

  def record_one_month_pay_as_history
    self.current = false unless base?
  end

  def employee_can_receive_salary
    return if employee&.employee? || employee&.human_resource?

    errors.add(:base, "Salary can only be added for an employee or an HR user")
  end

  def retire_previous_current
    previous = Salary.where(employee_id: employee_id, salary_type: salary_type, current: true)
    previous = previous.where.not(id: id) if persisted?
    previous.find_each { |line| line.update!(current: false) }
  end

  def currency_matches_existing_employee_currency
    expected_currency = Salary.where(employee_id: employee_id).where.not(id: id).order(created_at: :desc).pick(:currency)
    return if expected_currency.blank? || expected_currency == currency

    errors.add(:currency, "must stay #{expected_currency} for this employee")
  end
end
