# frozen_string_literal: true

# Base for plain-Ruby JSON serializers: subclasses implement #as_json.
class ApplicationSerializer
  def self.one(record, **context)
    new(record, **context).as_json if record
  end

  def self.many(records, **context)
    records.map { |record| new(record, **context).as_json }
  end

  def initialize(record, **context)
    @record = record
    @context = context
  end

  private

  attr_reader :record, :context
end
