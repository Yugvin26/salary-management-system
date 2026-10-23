# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportPolicy do
  let(:hr) { build(:user) }
  let(:employee) { build(:user, :employee, id: 10) }
  let(:actions) { %i[dashboard? departments? job_titles? countries? export?] }

  it "lets HR open every report" do
    policy = described_class.new(hr, :report)
    expect(actions.map { |action| policy.public_send(action) }).to all(be(true))
  end

  it "denies employees and visitors" do
    [ employee, nil ].each do |actor|
      policy = described_class.new(actor, :report)
      expect(actions.map { |action| policy.public_send(action) }).to all(be(false))
    end
  end
end
