# frozen_string_literal: true

require "rails_helper"

RSpec.describe SalaryPolicy do
  let(:hr) { build(:user, id: 1) }
  let(:employee) { build(:user, :employee, id: 10) }
  let(:own_salary) { Salary.new(employee_id: 10) }
  let(:other_salary) { Salary.new(employee_id: 11) }

  it "lets HR read and write salaries in their company" do
    salary = create(:salary)
    hr_user = create(:user, company: salary.employee.company)
    policy = described_class.new(hr_user, salary)
    expect([ policy.index?, policy.show?, policy.create?, policy.update? ]).to all(be(true))
  end

  it "does not let HR change their own salary" do
    hr_user = create(:user)
    salary = build(:salary, employee: hr_user)
    policy = described_class.new(hr_user, salary)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
  end

  it "lets an employee read only their own salary" do
    expect(described_class.new(employee, own_salary)).to be_show.and be_index
    expect(described_class.new(employee, other_salary).show?).to be(false)
  end

  it "never lets an employee write salaries" do
    policy = described_class.new(employee, own_salary)
    expect([ policy.create?, policy.update?, policy.destroy? ]).to all(be(false))
  end

  it "denies visitors" do
    expect(described_class.new(nil, own_salary).show?).to be(false)
  end

  describe "Scope" do
    let!(:mine) { create(:salary) }
    let!(:theirs) { create(:salary) }

    it "returns all salaries for HR" do
      expect(described_class::Scope.new(create(:user), Salary).resolve).to contain_exactly(mine, theirs)
    end

    it "returns only own salaries for an employee" do
      expect(described_class::Scope.new(mine.employee, Salary).resolve).to contain_exactly(mine)
    end

    it "returns nothing for visitors" do
      expect(described_class::Scope.new(nil, Salary).resolve).to be_empty
    end
  end
end
