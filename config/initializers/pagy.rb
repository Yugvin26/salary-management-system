# frozen_string_literal: true

require "pagy/extras/limit"
require "pagy/extras/overflow"
require "pagy/extras/array"

Pagy::DEFAULT[:limit] = 25
Pagy::DEFAULT[:limit_param] = :per_page
Pagy::DEFAULT[:limit_max] = 100
# Pages past the end return an empty list instead of raising.
Pagy::DEFAULT[:overflow] = :empty_page
Pagy::DEFAULT.freeze
