# frozen_string_literal: true

class SpaController < ApplicationController
  def index
    render template: "spa/index", layout: "application"
  end
end
