# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy do
  let(:hr) { build(:user, id: 1) }
  let(:employee) { build(:user, :employee, id: 10) }
  let(:other) { build(:user, :employee, id: 11) }

  describe "HR" do
    it "manages the directory" do
      policy = described_class.new(hr, User)
      expect([ policy.index?, policy.create? ]).to all(be(true))
      expect(described_class.new(hr, other)).to be_show.and be_update.and be_archive
    end

    it "cannot assign the HR role" do
      expect(described_class.new(hr, User)).not_to be_assign_hr_role
    end
  end

  describe "employee" do
    it "sees only their own record" do
      expect(described_class.new(employee, employee).show?).to be(true)
      expect(described_class.new(employee, other).show?).to be(false)
    end

    it "cannot browse or change the directory" do
      policy = described_class.new(employee, other)
      expect([ policy.index?, policy.create?, policy.update?, policy.archive?, policy.destroy? ]).to all(be(false))
    end

    it "cannot assign the HR role" do
      expect(described_class.new(employee, User)).not_to be_assign_hr_role
    end
  end

  describe "visitor" do
    it "is denied everything" do
      policy = described_class.new(nil, other)
      expect([ policy.index?, policy.show?, policy.create?, policy.update?, policy.archive? ]).to all(be(false))
    end
  end

  describe "#permitted_attributes" do
    it "includes role only when the user may assign it" do
      admin = build(:user, role: :company_admin)
      expect(described_class.new(admin, User).permitted_attributes).to include(:role)
      expect(described_class.new(hr, User).permitted_attributes).not_to include(:role)
      expect(described_class.new(employee, User).permitted_attributes).not_to include(:role)
    end

    it "never lets employee endpoints set the role" do
      expect(described_class.new(hr, User).permitted_employee_attributes).not_to include(:role)
    end
  end

  describe "Scope" do
    let!(:hr_user) { create(:user) }
    let!(:first) { create(:user, :employee) }
    let!(:second) { create(:user, :employee) }

    it "gives HR the employees and other HR users in their company" do
      expect(described_class::Scope.new(hr_user, User).resolve).to contain_exactly(hr_user, first, second)
    end

    it "gives a company admin employees and HR in that company" do
      admin = create(:user, role: :company_admin)
      expect(described_class::Scope.new(admin, User).resolve).to contain_exactly(hr_user, first, second)
    end

    it "limits an employee to themselves" do
      expect(described_class::Scope.new(first, User).resolve).to contain_exactly(first)
    end

    it "gives visitors nothing" do
      expect(described_class::Scope.new(nil, User).resolve).to be_empty
    end
  end
end
