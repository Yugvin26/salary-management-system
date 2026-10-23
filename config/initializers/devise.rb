# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = "hr@acme.local"
  require "devise/orm/active_record"

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [ :http_auth ]
  config.stretches = Rails.env.test? ? 1 : 12
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.sign_out_via = :delete
  config.navigational_formats = []
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
