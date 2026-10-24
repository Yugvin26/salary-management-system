# frozen_string_literal: true

module Api
  class CompanySettingsController < BaseController
    def show
      setting = current_setting
      authorize setting
      render_data setting_payload(setting)
    end

    def update
      setting = current_setting
      authorize setting
      if setting.update(setting_params)
        render_data setting_payload(setting)
      else
        render_errors(setting)
      end
    end

    private

    def current_setting
      current_user.company.setting || current_user.company.create_setting!
    end

    def setting_params
      params.require(:setting).permit(:primary_color, :accent_color, :background_color)
    end

    def setting_payload(setting)
      {
        primary_color: setting.primary_color,
        accent_color: setting.accent_color,
        background_color: setting.background_color
      }
    end
  end
end
