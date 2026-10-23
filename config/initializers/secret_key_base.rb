# frozen_string_literal: true

Rails.application.config.secret_key_base = if ENV["SECRET_KEY_BASE"].present?
                                             ENV["SECRET_KEY_BASE"]
                                           elsif Rails.env.local?
                                             "dev-secret-key-base-for-local-salary-management-only"
                                           else
                                             raise "SECRET_KEY_BASE is required outside development and test"
                                           end
