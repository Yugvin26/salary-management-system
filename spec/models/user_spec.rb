# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "persists an HR user and an employee on users and has no employees table" do
    hr = create(:user)
    employee = create(:user, :employee)
    expect(hr.reload.role).to eq("human_resource")
    expect(employee.reload.role).to eq("employee")
    expect(User.table_name).to eq("users")
    expect(ActiveRecord::Base.connection.tables).not_to include("employees")
  end

  it "rejects a user without a role" do
    user = build(:user, role: nil)
    expect(user).not_to be_valid
  end

  it "requires directory fields for employees" do
    user = build(:user, :employee, employee_id: nil, job_title: nil, work_mode: nil, hire_date: nil, department: nil, location: nil)
    user.valid?
    expect(user.employee_id).to match(/\AE\d{5,}\z/)
    user.employee_id = nil
    expect(user).not_to be_valid
    expect(user.errors.attribute_names).to include(:job_title, :work_mode, :hire_date, :department, :location)
  end

  it "does not authenticate an archived employee" do
    employee = create(:user, :employee, active: false)
    expect(employee.active_for_authentication?).to be(false)
  end

  describe "#name and #name=" do
    it "joins first and last name" do
      expect(build(:user, first_name: "Grace", last_name: "Hopper").name).to eq("Grace Hopper")
    end

    it "splits a full name on the first space" do
      user = build(:user)
      user.name = "Mary Ann Smith"
      expect([ user.first_name, user.last_name ]).to eq([ "Mary", "Ann Smith" ])
    end

    it "uses a placeholder last name for a single word" do
      user = build(:user)
      user.name = "Plato"
      expect([ user.first_name, user.last_name ]).to eq([ "Plato", "-" ])
    end
  end

  describe "employee_id" do
    it "auto-generates the next sequential id for employees" do
      create(:user, :employee, employee_id: "E00041")
      employee = create(:user, :employee, employee_id: nil)
      expect(employee.employee_id).to eq("E00042")
    end

    it "keeps an explicitly provided id" do
      expect(create(:user, :employee, employee_id: "E09999").employee_id).to eq("E09999")
    end

    it "does not generate an id for HR users" do
      expect(create(:user).employee_id).to be_nil
    end

    it "rejects a malformed id" do
      user = build(:user, :employee, employee_id: "X1")
      expect(user).not_to be_valid
      expect(user.errors[:employee_id]).to be_present
    end

    it "rejects a duplicate id" do
      create(:user, :employee, employee_id: "E00100")
      expect(build(:user, :employee, employee_id: "E00100")).not_to be_valid
    end
  end

  describe "authentication" do
    it "requires an HR user to be active to authenticate" do
      expect(create(:user, active: false).active_for_authentication?).to be(false)
    end

    it "reports archived as the inactive message for employees" do
      expect(create(:user, :employee, active: false).inactive_message).to eq(:archived)
    end

    it "requires a unique, well-formed email" do
      create(:user, email: "dup@acme.local")
      expect(build(:user, email: "dup@acme.local")).not_to be_valid
      expect(build(:user, email: "not-an-email")).not_to be_valid
    end

    it "requires first and last name" do
      user = build(:user, first_name: nil, last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors.attribute_names).to include(:first_name, :last_name)
    end
  end

  describe "work_mode" do
    it "accepts the known modes" do
      %w[remote hybrid in_office].each do |mode|
        expect(build(:user, :employee, work_mode: mode)).to be_valid
      end
    end

    it "rejects an unknown mode" do
      expect { build(:user, :employee, work_mode: "moon") }.to raise_error(ArgumentError)
    end
  end

  describe "associations" do
    it "returns only the current base salary" do
      employee = create(:user, :employee)
      create(:salary, employee: employee, current: false, amount: 10, effective_on: Date.new(2020, 1, 1))
      create(:salary, employee: employee, salary_type: :bonus, current: true, amount: 5)
      base = create(:salary, employee: employee, current: true, amount: 20)
      expect(employee.reload.current_base_salary).to eq(base)
    end

    it "deletes salaries with the user" do
      employee = create(:user, :employee)
      create(:salary, employee: employee)
      expect { employee.destroy }.to change(Salary, :count).by(-1)
    end
  end
end
