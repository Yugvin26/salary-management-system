# frozen_string_literal: true

# Context: `actors` ({ whodunnit => User }) and `currency` avoid per-version queries.
class SalaryVersionSerializer < ApplicationSerializer
  def self.many(versions, **context)
    actors = User.where(id: versions.filter_map(&:whodunnit)).index_by { |user| user.id.to_s }
    super(versions, actors: actors, **context)
  end

  def as_json
    {
      id: record.id,
      event: record.event,
      changeset: changeset,
      whodunnit: record.whodunnit,
      created_at: record.created_at,
      updated_at: changeset&.dig("updated_at")&.last || record.created_at,
      amount: amount,
      formatted_amount: formatted_amount,
      salary_type: salary_type,
      actor: actor
    }
  end

  private

  def changeset
    @changeset ||= record.changeset
  end

  def salary_type
    values = changeset&.dig("salary_type")
    raw = values&.compact&.last
    named = raw.is_a?(Integer) ? Salary.salary_types.key(raw) : raw
    named.presence || context[:salary_type]
  end

  def currency
    changeset&.dig("currency")&.last || context[:currency]
  end

  def amount_cents
    changeset&.dig("amount_cents")&.last || changeset&.dig("amount_cents")&.first
  end

  def amount
    return if amount_cents.blank? || currency.blank?

    Salary.amount_string(amount_cents, currency)
  end

  def formatted_amount
    return if amount_cents.blank? || currency.blank?

    Money.new(amount_cents, currency).format
  end

  def actor
    user = context.fetch(:actors, {})[record.whodunnit]
    { id: user.id, name: user.name, email: user.email } if user
  end
end
