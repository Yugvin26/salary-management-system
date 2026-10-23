# frozen_string_literal: true

require "rails_helper"

RSpec.describe Salary, type: :model do
  it "replaces the previous current line of the same type" do
    employee = create(:user, :employee)
    previous = create(:salary, employee: employee, amount: 80_000, current: true, effective_on: Date.new(2023, 1, 1))
    current = create(:salary, employee: employee, amount: 90_000, current: true, effective_on: Date.new(2024, 1, 1))

    expect(current.reload).to be_current
    expect(previous.reload).not_to be_current
  end

  it "rejects a non-positive amount and a currency that is not three uppercase letters" do
    expect(build(:salary, amount: 0)).not_to be_valid
    expect(build(:salary, amount: -1)).not_to be_valid
    expect(build(:salary, currency: "usd")).not_to be_valid
    expect(build(:salary, currency: "US")).not_to be_valid
  end

  it "writes PaperTrail versions for create and for marking a line not current" do
    hr = create(:user)
    employee = create(:user, :employee)
    PaperTrail.request.whodunnit = hr.id.to_s
    salary = create(:salary, employee: employee, current: true)
    expect(salary.versions.map(&:event)).to include("create")

    salary.update!(current: false)
    update_version = salary.versions.order(:id).last
    expect(update_version.event).to eq("update")
    expect(update_version.whodunnit).to eq(hr.id.to_s)
    expect(update_version.changeset["current"]).to eq([ true, false ])
  end

  describe "amount_cents as the only stored value" do
    it "has no amount column" do
      expect(described_class.column_names).to include("amount_cents")
      expect(described_class.column_names).not_to include("amount")
    end

    it "stores 2-decimal currencies in cents" do
      salary = create(:salary, amount: "1234.56", currency: "USD")
      expect(salary.reload.amount_cents).to eq(123_456)
      expect(salary.amount).to eq(BigDecimal("1234.56"))
    end

    it "stores 0-decimal currencies without scaling" do
      salary = create(:salary, amount: 50_000, currency: "JPY")
      expect(salary.reload.amount_cents).to eq(50_000)
      expect(salary.amount_string).to eq("50000")
    end

    it "stores 3-decimal currencies in thousandths" do
      salary = create(:salary, amount: "12.345", currency: "KWD")
      expect(salary.reload.amount_cents).to eq(12_345)
      expect(salary.amount_string).to eq("12.345")
    end

    it "does not depend on the order amount and currency are assigned" do
      salary = described_class.new(amount: 10, currency: "JPY")
      salary.valid?
      expect(salary.amount_cents).to eq(10)
    end

    it "formats the money value with the currency symbol" do
      expect(create(:salary, amount: 90_000, currency: "USD").pay.format).to eq("$90,000.00")
    end

    it "rejects a non-numeric or blank amount" do
      expect(build(:salary, amount: "abc")).not_to be_valid
      expect(build(:salary, amount: "")).not_to be_valid
      expect(build(:salary, amount: nil)).not_to be_valid
    end

    it "rejects an unknown currency code" do
      salary = build(:salary, amount: 10, currency: "ZZZ")
      expect(salary).not_to be_valid
    end
  end

  describe ".amount_string" do
    it "uses each currency's exponent" do
      expect(described_class.amount_string(12_345, "USD")).to eq("123.45")
      expect(described_class.amount_string(12_345, "JPY")).to eq("12345")
      expect(described_class.amount_string(12_345, "KWD")).to eq("12.345")
    end
  end

  describe "employee rules" do
    it "allows a salary for an HR user" do
      expect(build(:salary, employee: create(:user))).to be_valid
    end

    it "rejects a company admin" do
      salary = build(:salary, employee: create(:user, role: :company_admin))
      expect(salary).not_to be_valid
      expect(salary.errors[:base]).to include("Salary can only be added for an employee or an HR user")
    end

    it "keeps one currency per employee" do
      employee = create(:user, :employee)
      create(:salary, employee: employee, currency: "USD")
      other_currency = build(:salary, employee: employee, currency: "EUR")
      expect(other_currency).not_to be_valid
      expect(other_currency.errors[:currency].first).to include("USD")
    end
  end

  describe "current lines" do
    it "keeps a bonus in history and leaves the current base in place" do
      employee = create(:user, :employee)
      base = create(:salary, employee: employee, salary_type: :base, current: true, amount: 120_000)
      bonus = create(:salary, employee: employee, salary_type: :bonus, current: true, amount: 1_000, effective_on: Date.new(2026, 10, 1))
      commission = create(:salary, employee: employee, salary_type: :commission, amount: 500, effective_on: Date.new(2026, 9, 1))

      expect(base.reload).to be_current
      expect(bonus.reload).not_to be_current
      expect(commission.reload).not_to be_current
      expect(bonus.versions.map(&:event)).to include("create")

      payout = described_class.monthly_payout(employee, on: Date.new(2026, 10, 23))
      expect(payout[:base_monthly]).to eq("10000.00")
      expect(payout[:bonus]).to eq("1000.00")
      expect(payout[:commission]).to eq("0.00")
      expect(payout[:total]).to eq("11000.00")
    end

    it "does not retire another employee's current line" do
      first = create(:salary, current: true)
      create(:salary, current: true)
      expect(first.reload).to be_current
    end

    it "leaves a non-current line untouched when added" do
      employee = create(:user, :employee)
      base = create(:salary, employee: employee, current: true)
      create(:salary, employee: employee, current: false, effective_on: Date.new(2020, 1, 1))
      expect(base.reload).to be_current
    end
  end

  it "rejects an unknown salary type" do
    expect(build(:salary, salary_type: "stock")).not_to be_valid
  end

  it "requires an effective date" do
    expect(build(:salary, effective_on: nil)).not_to be_valid
  end
end
