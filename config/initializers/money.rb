# frozen_string_literal: true

MoneyRails.configure do |config|
  config.default_currency = :usd
  config.locale_backend = :currency
  config.rounding_mode = BigDecimal::ROUND_HALF_UP
  config.default_format = {
    no_cents_if_whole: false,
    thousands_separator: ",",
    decimal_mark: "."
  }
end
