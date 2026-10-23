# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reference data policies" do
  let(:hr) { build(:user, id: 1) }
  let(:employee) { build(:user, :employee, id: 10) }

  [ DepartmentPolicy, LocationPolicy ].each do |policy_class|
    describe policy_class do
      it "lets HR perform every action" do
        policy = policy_class.new(hr, policy_class.name.delete_suffix("Policy").constantize)
        expect([ policy.index?, policy.show?, policy.create?, policy.update?, policy.destroy? ]).to all(be(true))
      end

      it "denies employees and visitors" do
        [ employee, nil ].each do |actor|
          policy = policy_class.new(actor, policy_class.name.delete_suffix("Policy").constantize)
          expect([ policy.index?, policy.show?, policy.create?, policy.update?, policy.destroy? ]).to all(be(false))
        end
      end

      it "scopes to nothing for non-HR" do
        model = policy_class.name.delete_suffix("Policy").constantize
        create(model.name.underscore.to_sym)
        expect(policy_class::Scope.new(create(:user), model).resolve.count).to eq(1)
        expect(policy_class::Scope.new(employee, model).resolve).to be_empty
        expect(policy_class::Scope.new(nil, model).resolve).to be_empty
      end
    end
  end
end
